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
    render subtitle: "CHECKING $>_ #{action.check}"
    action.check!
  end

  def approve action
    color = action.obsolete ? :green: :yellow
    puts "┣━\ #{format color, :bold} #{action.chain.join(" > ")} #{format} #{format :cyan}#{action.job.params}#{format}"
    puts "┃\ \ \ #{action.line}\e[2m#{" UNLESS " if action.check}#{action.check}\e[0m" if action.class == Command
    action.approve
  end

  def apply action
    action.apply
  end

  def render text=nil, title: nil, subtitle: nil, first: false
    puts "\n┏━#{format :invert, :bold}#{" "*16}#{title}#{" "*16}#{format}\n┃" if title
    puts "┃ #{text}" if text
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
      end
    end
    return output
  end
end
