class CLI
  def initialize core, params
    options = Options.new params

    # parse
    render section: "RBCM starting", first: true
    core.parse

    # check
    render section: "CHECKING #{core.nodes.count} nodes"
    core.actions.each do |action|
      check action
    end

    # approve
    render section: "APPROVING #{core.actions.select{|a| a.obsolete == false}.count} actions"
    core.actions.resolve_triggers.unapprovable.each do |action|
      approve action
    end
    core.actions.resolve_triggers.approvable.each do |action|
      approve action
    end

    # apply
    render section: "APPLYING #{core.actions.approved.count} actions"
    core.actions.approved.resolve_dependencies.each do |action|
      apply action
    end

    # finish
    puts "┗━━━━"
  end

  private

  def check action
    render checking: action.check
    action.check!
  end

  def approve action
    @action = action
    render :title, color: action.obsolete ? :green : :yellow
    render :command if action.class == Command
    render :siblings if action.siblings.any?
    return if action.obsolete or action.approved or action.not_triggered
    render :diff if action.class == FileAction
    render :prompt
    input = STDIN.gets.chomp.to_sym
    action.approve! if [:a, :y].include? input
    siblings.each.approve! if input == :a
    action.node.triggered << action.trigger # move to action < v
    if (triggered = action.trigger.compact - action.node.triggered).any?
      puts "┃\ \ \ triggered: \e[30;46m\e[1m #{triggered.join(", ")} \e[0m; again: #{action.trigger.-(triggered).join(", ")}"
    end
  end

  def apply action
    response = action.apply!
    render :title, color: response.exitstatus == 0 ? :green : :red
    render :command if response.exitstatus != 0
    puts response.to_s.chomp if response.length > 0
  end

  def render element=nil, section: nil, color: nil, first: false, response: nil, checking: nil
    if section
      puts "#{first ? nil : "┗━━━━"}\n\n┏━#{format :invert, :bold}#{" "*16}#{section}#{" "*16}#{format}\n┃"
    elsif element == :title
      puts "┣━\ #{format color, :bold} #{@action.chain.join(" > ")} #{format}\ \ #{format :cyan}#{@action.job.params}#{format}"
    elsif element == :command
      puts "┃\ \ \ #{@action.line}\e[2m#{" UNLESS " if @action.check}#{@action.check}\e[0m"
    elsif element == :siblings
      puts "┃\ \ \ siblings: #{format :magenta}#{@action.siblings.each.node.each.name.join(", ")}#{format}"
    elsif element == :prompt
      puts "┃\ \ \ siblings: #{format :magenta}#{@action.siblings.each.node.each.name.join(", ")}#{format}"
    elsif element == :diff
      puts "┃\ \ \ " + Diffy::Diff.new(
        @action.node.remote.files[@action.path],
        @action.node.files[@action.path]
      ).to_s(:color).split("\n").join("\n┃\ \ \ ")
    elsif checking
      puts "┃\ \ \ CHECKING #{checking}"
    else
    end
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
end
