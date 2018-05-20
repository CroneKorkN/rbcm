class CLI
  def initialize core, params
    options = Options.new params

    #
    # parse
    #
    render title: "RBCM starting", first: true
    core.parse

    #
    # check
    #
    render title: "CHECKING #{core.nodes.count} nodes"
    core.actions.each do |action|
      check action
    end

    #
    # approve
    #
    render title: "APPROVING #{core.actions.select{|a| a.obsolete == false}.count} actions"
    core.actions.resolve_triggers.unapprovable.each do |action|
      approve action
    end
    core.actions.resolve_triggers.approvable.each do |action|
      approve action
    end

    #
    # apply
    #
    render title: "APPLYING #{core.actions.approved.count} actions"
    core.actions.approved.resolve_dependencies.each do |action|
      apply action
    end
  end

  private

  def check action
    render "CHECKING $>_ #{action.check}"
    action.check!
  end

  def approve action
    color = action.obsolete ? :green: :yellow
    puts "┣━\ #{format color, :bold} #{action.chain.join(" > ")} #{format}\ \ #{format :cyan}#{action.job.params}#{format}"
    puts "┃\ \ \ #{action.line}\e[2m#{" UNLESS " if action.check}#{action.check}\e[0m" if action.class == Command
    puts "┃\ \ \ siblings: #{format :magenta}#{action.siblings.each.node.each.name.join(", ")}#{format}" if action.siblings.any?
    return if action.obsolete or action.approved or action.not_triggered
    puts diff action if action.class == FileAction
    print "┃\ \ \ APROVE #{"[a]ll, " if action.siblings.any?}[y]es, [N]o: " # o: apply to ahole group
    action.approve
    if (triggered = action.trigger.compact - action.node.triggered).any?
      puts "┃\ \ \ triggered: \e[30;46m\e[1m #{triggered.join(", ")} \e[0m; again: #{action.trigger.-(triggered).join(", ")}"
    end
  end

  def apply action
    action.apply
  end

  def render text=nil, title: nil, first: false
    puts "#{first ? nil : "┗━━━━━"}\n\n┏━#{format :invert, :bold}#{" "*16}#{title}#{" "*16}#{format}\n┃" if title
    puts "┃\ \ \ #{text}" if text
  end

  def format *params, **_
    output = "\e[0m"
    params.each do |param|
      case param
      when :reset
        output += "\e[0m"
      when :bold
        output +=  "\e[1m"
      when :invert
        output +=  "\e[7m"
      when :red
        output +=  "\e[30;41m"
      when :green
        output +=  "\e[30;42m"
      when :yellow
        output +=  "\e[30;43m"
      when :cyan
        output +=  "\e[36m"
      when :magenta
        output +=  "\e[35m"
      end
    end
    return output
  end

  def diff action
    "┃\ \ \ " + Diffy::Diff.new(
      action.node.remote.files[action.path],
      action.node.files[action.path]
    ).to_s(:color).split("\n").join("\n┃\ \ \ ")
  end
end
