class CLI
  def initialize params
    options = Options.new params
    render section: "RBCM starting", first: true
    # bootstrap
    @rbcm = rbcm = RBCM.new params[0] || `pwd`.chomp
    render :project
    render :capabilities
    # parse
    rbcm.parse
    render :nodes
    # check
    render section: "CHECKING #{rbcm.actions.checkable.count} actions on #{rbcm.nodes.count} nodes"
    rbcm.actions.each do |action|
      check action
    end
    # approve
    render section: "APPROVING #{rbcm.actions.approvable.count}/#{rbcm.actions.unneccessary.count} actions"
    approve rbcm.actions.unneccessary.resolve_triggers
    while action = rbcm.actions.approvable.resolve_triggers.first
      approve action
      if action.approved?
        approve action.siblings
        approve action.same_file if action.class == Action::File
      end
    end
    # apply
    render section: "APPLYING #{rbcm.actions.approved.count} actions"
    while action = rbcm.actions.applyable.resolve_dependencies.first
      apply action
    end
    # finish
    render :applied
    puts "┗━━──"
  end

  private

  def check action
    @action = action
    render checking: action.check
    action.check!
  end

  def approve actions
    [actions].flatten(1).each do |action|
      @action = action
      render :title, color: (action.obsolete ? :green : :yellow)
      render :command if action.class == Action::Command
      next if not action.approvable?
      render :siblings if action.siblings.any?
      render :source if action.source.any?
      render :diff if action.class == Action::File
      render :prompt
      sleep 0.25 unless [:a,:y,:n].include? r = STDIN.getch.to_sym # avoid 'ctrl-c'-trap
      action.approve! r
      render :approved
      render :triggered if action.triggered.any?
    end
  end

  def apply actions
    [actions].flatten(1).each do |action|
      @action = action
      response = action.apply!
      render :title, color: response.exitstatus == 0 ? :green : :red
      render :command if action.class == Action::Command and response.exitstatus != 0
      render response: response if response.length > 0
    end
  end

  def render element=nil, section: nil, color: nil, first: false, response: nil, checking: nil
    prefix = "┃   "
    if section
      out "#{first ? nil : "┗━━──"}\n\n┏━━#{format :invert, :bold}#{" "*16}#{section}#{" "*16}#{format}━──\n┃"
    elsif element == :title
      triggerd_by = "#{format :trigger, :bold} #{@action.triggered_by.join(", ")} " if @action.triggered_by.any?
        out "┣━ #{triggerd_by}#{format color, :bold} #{(@action.chain).join(" > ")} " +
        "#{format} #{format :params}#{@action.job.params if @action.job}#{format}" +
        " #{format :tag}#{"tags: " if @action.tags.any?}#{@action.tags.join(", ")}#{format}"
    elsif element == :capabilities
      out prefix + "capabilities: #{Node::Sandbox.capabilities.join(", ")}"
    elsif element == :project
      out prefix + "project: #{@rbcm.project.files.count} ruby files, #{@rbcm.project.templates.count} templates"
      out prefix + "  #{@rbcm.project.directories.count} directories, #{@rbcm.project.other.count} other files"
    elsif element == :nodes
      out prefix + @rbcm.nodes.values.collect{ |node|
        name = node.name.to_s.+(":").ljust(@rbcm.nodes.keys.each.length.max+1, " ")
        jobs = node.jobs.count.to_s.rjust(@rbcm.nodes.values.collect{|node| node.jobs.count}.max.digits.count, " ")
        actions = node.actions.count.to_s.rjust(@rbcm.nodes.values.collect{|node| node.actions.count}.max.digits.count, " ")
        "#{name} #{jobs} jobs, #{actions} actions"
      }.flatten(1).join("\n#{prefix}")
    elsif element == :command
      check_string = " UNLESS #{@action.check}" if @action.check
      out prefix + "$> #{@action.line}\e[2m#{check_string}\e[0m"
    elsif element == :siblings
      string = @action.siblings.collect do |sibling|
        "#{sibling.neccessary? ? format(:yellow) : format(:green)} #{sibling.node.name} #{format}"
      end.join
      out prefix + "#{format :siblings}siblings:#{format} #{string}"
    elsif element == :source
      out prefix + "source: #{format :bold}#{@source.join("#{format}, #{format :bold}")}#{format}"
    elsif element == :prompt
      color = @action.siblings.any? ? :siblings : :light
      print prefix + "APPROVE? #{format color}[a]ll#{format}, [y]es, [N]o: "
    elsif element == :triggered
      out prefix +
        "triggered: #{format :trigger} #{@action.triggered.join(", ")} \e[0m;" +
        " again: #{@action.trigger.-(@action.triggered).join(", ")}"
    elsif element == :diff
      out prefix[0..-2] + Diffy::Diff.new(
        @action.node.files[@action.path].content,
        @action.content
      ).to_s(:color).split("\n").join("\n#{prefix[0..-2]}")
    elsif element == :approved
      string = @action.approved? ? "#{format :green} APPROVED" : "#{format :red} DECLINED"
      puts "#{string} #{format}"
    elsif element.class == String
      out prefix + "#{element}"
    elsif checking
      out prefix + "CHECKING #{@action.node.name}: #{checking}"
    elsif response
      out prefix + response.to_s.chomp.split("\n").join("\n#{prefix}")
    elsif element == :applied
      out prefix
      out "┣━\ #{format :green, :bold} #{@rbcm.actions.succeeded.count} secceeded #{format}"
      out "┣━\ #{format :red, :bold} #{@rbcm.actions.failed.count} failed #{format}"
    else
    end
  end

  def out line
    puts "\r#{line}"
  end

  def format *params, **_
    "\e[0m" + {
      reset:    "\e[0m",
      bold:     "\e[1m",
      light:    "\e[2m",
      invert:   "\e[7m",
      trigger:  "\e[30;46m",
      red:      "\e[30;101m",
      green:    "\e[30;42m",
      yellow:   "\e[30;43m",
      cyan:     "\e[36m",
      tag:      "\e[35m",
      params:   "\e[36m",
      siblings: "\e[35m"
    }.select{ |key, _|
      params.include? key
    }.values.join
  end
end
