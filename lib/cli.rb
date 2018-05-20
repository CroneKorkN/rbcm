class CLI
  def initialize params
    options = Options.new params
    # parse
    render section: "RBCM starting", first: true
    core = Core.new params[0] || `pwd`.chomp
    render :capabilities
    core.parse
    # check
    render section: "CHECKING #{core.nodes.count} nodes"
    core.actions.each do |action|
      check action
    end
    # approve
    render section: "APPROVING #{core.actions.select{|a| a.obsolete == false}.count} actions"
    approve core.actions.resolve_triggers.unapprovable
    while action = core.actions.resolve_triggers.approvable.first
      approve action
      approve action.siblings if action.approved
    end
    # apply
    render section: "APPLYING #{core.actions.approved.count} actions"
    core.actions.approved.resolve_dependencies.each do |action|
      apply action
    end
    puts "┗━━──"
    # finish
  end

  private

  def check action
    render checking: action.check
    action.check!
  end

  def approve actions
    [actions].flatten(1).each do |action|
      @action = action
      render :title, color: action.obsolete ? :green : :yellow
      render :command if action.class == Command
      render :siblings if action.siblings.any?
      return if action.obsolete or action.approved or action.not_triggered
      render :diff if action.class == FileAction
      render :prompt
      action.approve! STDIN.gets.chomp.to_sym
      render :triggered if action.triggered.any?
    end
  end

  def apply action
    @action = action
    response = action.apply!
    render :title, color: response.exitstatus == 0 ? :green : :red
    render :command if response.exitstatus != 0
    render response: response if response.length > 0
  end

  def render element=nil, section: nil, color: nil, first: false, response: nil, checking: nil
    prefix = "┃\ \ \ "
    if section
      puts "#{first ? nil : "┗━━──"}\n\n┏━━#{format :invert, :bold}#{" "*16}#{section}#{" "*16}#{format}━──\n┃"
    elsif element == :title
      triggerd_by = "#{format :trigger, :bold} #{@action.triggered_by.join(", ")} " if @action.triggered_by.any?
      puts "┣━\ #{triggerd_by}#{format color, :bold} #{@action.chain.join(" > ")} #{format}\ \ #{format :cyan}#{@action.job.params}#{format}"
    elsif element == :capabilities
      puts prefix + "CAPABILITIES #{Sandbox.capabilities.join(", ")}"
    elsif element == :command
      puts prefix + "$> #{@action.line}\e[2m#{" UNLESS " if @action.check}#{@action.check}\e[0m"
    elsif element == :siblings
      puts prefix + "siblings: #{format :magenta}#{@action.siblings.each.node.each.name.join(", ")}#{format}"
    elsif element == :prompt
      print prefix + "APPROVE? #{"(" if @action.siblings.empty?}[a]ll#{")" if @action.siblings.empty?}, [y]es, [N]o > "
    elsif element == :triggered
      puts prefix + "triggered: \e[30;46m\e[1m #{@action.triggered.join(", ")} \e[0m; again: #{@action.trigger.-(@action.triggered).join(", ")}"
    elsif element == :diff
      puts prefix + Diffy::Diff.new(
        @action.node.remote.files[@action.path],
        @action.node.files[@action.path]
      ).to_s(:color).split("\n").join("\n┃\ \ ")
    elsif element.class == String
      puts prefix + "#{element}"
    elsif checking
      puts prefix + "CHECKING #{checking}"
    elsif response
      puts prefix + response.to_s.chomp.split("\n").join("\n┃\ \ \ ")
    else
    end
  end

  def format *params, **_
    "\e[0m" + {
      reset:   "\e[0m",
      bold:    "\e[1m",
      invert:  "\e[7m",
      trigger: "\e[30;46m",
      red:     "\e[30;101m",
      green:   "\e[30;42m",
      yellow:  "\e[30;43m",
      cyan:    "\e[36m",
      magenta: "\e[35m",
    }.select{ |key, _|
      params.include? key
    }.values.join
  end
end
