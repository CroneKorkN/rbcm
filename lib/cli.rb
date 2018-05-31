class CLI
  def initialize params
    options = Options.new params
    render section: "RBCM starting", first: true
    # bootstrap
    @core = core = Core.new params[0] || `pwd`.chomp
    render :capabilities
    # parse
    core.parse
    render :nodes
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
      approve @core.actions.file(action.path) - [action] if action.class == FileAction
      approve core.actions.file action.path if action.approved and action.class == FileAction
    end
    # apply
    render section: "APPLYING #{core.actions.approved.count} actions"
    apply core.actions.approved.resolve_dependencies
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
      render :title, color: (action.obsolete ? :green : :yellow)
      render :command if action.class == Command
      render :siblings if action.siblings.any?
      render :source if action.source.any?
      return if action.obsolete or action.approved or action.not_triggered
      render :diff if action.class == FileAction
      render :prompt
      action.approve! STDIN.gets.chomp.to_sym
      render :triggered if action.triggered.any?
    end
  end

  def apply actions
    [actions].flatten(1).each do |action|
      @action = action
      response = action.apply!
      render :title, color: response.exitstatus == 0 ? :green : :red
      render :command if response.exitstatus != 0
      render response: response if response.length > 0
    end
    render :applied
  end

  def render element=nil, section: nil, color: nil, first: false, response: nil, checking: nil
    prefix = "┃   "
    if section
      out "#{first ? nil : "┗━━──"}\n\n┏━━#{format :invert, :bold}#{" "*16}#{section}#{" "*16}#{format}━──\n┃"
    elsif element == :title
      triggerd_by = "#{format :trigger, :bold} #{@action.triggered_by.join(", ")} " if @action.triggered_by.any?
      out "┣━ #{triggerd_by}#{format color, :bold} #{@action.chain.join(" > ")} " +
        "#{format} #{format :cyan}#{@action.job.params}#{format}"
    elsif element == :capabilities
      out prefix + "CAPABILITIES #{Sandbox.capabilities.join(", ")}"
    elsif element == :nodes
      out prefix + @core.nodes.values.collect{ |node|
        name = node.name.+(":").ljust(@core.nodes.keys.each.length.max+1, " ")
        jobs = node.jobs.count.to_s.rjust(@core.nodes.values.collect{|node| node.jobs.count}.max.digits.count, " ")
        actions = node.actions.count.to_s.rjust(@core.nodes.values.collect{|node| node.actions.count}.max.digits.count, " ")
        "#{name} #{jobs} jobs, #{actions} actions"
      }.flatten(1).join("\n#{prefix}")
    elsif element == :command
      check_string = " UNLESS #{@action.check}" if @action.check
      out prefix + "$> #{@action.line}\e[2m#{check_string}\e[0m"
    elsif element == :siblings
      siblings_string = @action.siblings.each.node.each.name.join(", ")
      out prefix + "siblings: #{format :magenta}#{siblings_string}#{format}"
    elsif element == :source
      out prefix + "source: #{format :bold}#{@source.join("#{format}, #{format :bold}")}#{format}"
    elsif element == :prompt
      color = @action.siblings.any? ? :magenta : :light
      print prefix + "APPROVE? #{format color}[a]ll#{format}, [y]es, [N]o > "
    elsif element == :triggered
      out prefix +
        "triggered: #{format :trigger} #{@action.triggered.join(", ")} \e[0m;" +
        " again: #{@action.trigger.-(@action.triggered).join(", ")}"
    elsif element == :diff
      out prefix[0..-2] + Diffy::Diff.new(
        @action.node.files[@action.path],
        @action.content
      ).to_s(:color).split("\n").join("\n#{prefix[0..-2]}")
    elsif element.class == String
      out prefix + "#{element}"
    elsif checking
      out prefix + "CHECKING #{checking}"
    elsif response
      out prefix + response.to_s.chomp.split("\n").join("\n#{prefix}")
    elsif element == :applied
      out prefix
      out "┣━\ #{format :green, :bold} #{@core.actions.succeeded.count} secceeded #{format}"
      out "┣━\ #{format :red, :bold} #{@core.actions.failed.count} failed #{format}"
    else
    end
  end

  def out line
    puts "\r#{line}"
  end

  def format *params, **_
    "\e[0m" + {
      reset:   "\e[0m",
      bold:    "\e[1m",
      light:   "\e[2m",
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
