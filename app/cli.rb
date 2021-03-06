class RBCM::CLI
  def initialize argv
    render section: "RBCM starting", first: true
    args = Hash[argv.join(' ').scan(/--?([^=\s]+)(?:[=\s](\S+))?/)]
    # functions
    encrypt args["encrypt"] if args["encrypt"]
    decrypt args["decrypt"] if args["decrypt"]
    # start
    render :args, content: args
    # bootstrap
    @rbcm = rbcm = RBCM::Core.new argv[0] || `pwd`.chomp
    render :project
    render :capabilities
    # parse
    rbcm.parse
    render :nodes
    # check
    render section: "CHECKING #{rbcm.actions.checkable.count} actions on #{rbcm.nodes.count} nodes"
    rbcm.actions.node(args["node"]).each do |action|
      check action
    end
    # approve
    render section: "APPROVING #{rbcm.actions.approvable.count}/#{rbcm.actions.unneccessary.count} actions"
    approve rbcm.actions.unneccessary.resolve_triggers
    while action = rbcm.actions.node(args["node"]).approvable.resolve_triggers.first
      approve action
      if action.approved?
        approve action.siblings
        approve action.same_file if action.class == RBCM::Action::File
      end
    end
    # apply
    render section: "APPLYING #{rbcm.actions.approved.count} actions"
    while action = rbcm.actions.applyable.resolve_dependencies.first
      apply action
    end
    # finish
    render :applied
  end

  private

  def encrypt text
    puts "┃   encrypting: '#{text[0..40]}#{"..." if text.length > 40}'"
    print "┃   enter password: "
    puts "┃   #{text.encrypt STDIN.gets.chomp}"
    puts "┗━━──"
    exit 0
  end

  def decrypt text
    puts "┃   encrypting: '#{text[0..40]}#{"..." if text.length > 40}'"
    print "┃   enter password: "
    puts "┃   #{text.decrypt STDIN.gets.chomp}"
    puts "┗━━──"
    exit 0
  end

  def check action
    @action = action
    if action.class == RBCM::Action::Command
      render checking: action.check.collect{|a| a.force_encoding(Encoding::UTF_8)}.join("; ") if action.checkable?
    elsif action.class == RBCM::Action::File
      render checking: action.job.params[0]
    end
    action.check!
  end

  def approve actions
    [actions].flatten(1).each do |action|
      @action = action
      render :title, color: (action.obsolete ? :green : :yellow)
      next if not action.approvable?
      render :siblings if action.siblings.any?
      render :source if action.source.flatten.compact.any?
      render :diff if action.class == RBCM::Action::File
      render :prompt
      sleep 0.25 unless [:a,:y,:n,:i].include? r = STDIN.getch.to_sym # avoid 'ctrl-c'-trap
      (binding.pry; sleep 1) if r == :i
      (puts; exit) if r == :q
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
      render response: response if response.to_s.length > 0 and action.class == RBCM::Action::Command
    end
  end

  def render element=nil, section: nil, color: nil, first: false, response: nil, checking: nil, content: nil
    prefix = "┃   "
    if section
      out "#{first ? nil : "┗━━──"}\n\n┏━━#{format :invert, :bold}#{" "*16}#{section}#{" "*16}#{format}━──\n┃"
    elsif element == :args
      out "#{prefix}ARGUMENTS #{content.to_s}"
    elsif element == :title
      triggered_by = "#{format :trigger, :bold} #{@action.triggered_by.join(", ")} " if @action.triggered_by.any?
      tags = "#{format :tag}tags: #{@action.tags.join(", ")}#{format}"
        out "┣━ #{triggered_by}#{format color, :bold} #{@action.chain.flatten.compact.join(" > ")} #{format} #{tags if @action.tags.any?}"+
        "\n#{prefix}#{format :params}#{@action.job.params if @action.job}#{format}"
    elsif element == :capabilities
    elsif element == :project
      ([@rbcm.project] + @rbcm.project.all_addons).each do |project|
        out "┣━  #{project.class}#{" #{project.type}: #{project.name}" if project.class == RBCM::Addon}"
        out prefix + "#{project.files.count} ruby files, #{project.templates.count} templates #{project.directories.count} directories, #{project.other.count} other files"
        out prefix + "capabilities: #{project.capabilities.join(", ")}"
        out prefix + "templates: #{project.templates.each.clean_path.join(", ")}"
      end
    elsif element == :nodes
      out "┣━  NODES #{@rbcm.nodes.count}"
      out prefix + @rbcm.nodes.values.collect{ |node|
        name = node.name.to_s.+(":").ljust(@rbcm.nodes.keys.each.length.max+1, " ")
        jobs = node.jobs.count.to_s.rjust(@rbcm.nodes.values.collect{|node| node.jobs.count}.max.digits.count, " ")
        actions = node.actions.count.to_s.rjust(@rbcm.nodes.values.collect{|node| node.actions.count}.max.digits.count, " ")
        provides = "\n┃     provides #{node.providers.collect{|p| p[:name]}.join(", ")}"
        "#{name} #{jobs} jobs, #{actions} actions #{provides if node.providers.any?}"
      }.flatten(1).join("\n#{prefix}")
    elsif element == :command
      check_string = " UNLESS #{@action.check.join("; ")}" if @action.check.any?
      out prefix + "$> #{@action.line}\e[2m#{check_string}\e[0m"
    elsif element == :siblings
      string = @action.siblings.collect do |sibling|
        "#{sibling.neccessary? ? format(:yellow) : format(:green)} #{sibling.job.node.name} #{format}"
      end.join
      out prefix + "#{format :siblings}siblings:#{format} #{string}"
    elsif element == :source
      out prefix + "source: #{format :bold}#{@action.source.join("#{format}, #{format :bold}")}#{format}"
    elsif element == :prompt
      color = @action.siblings.any? ? :siblings : :light
      print prefix + "APPROVE? #{format color}[a]ll#{format}, [y]es, [N]o, [i]nteractive, [q]uit: "
    elsif element == :triggered
      out prefix +
        "triggered: #{format :trigger} #{@action.triggered.join(", ")} \e[0m;" +
        " again: #{@action.trigger.-(@action.triggered).join(", ")}"
    elsif element == :diff
      out prefix + Diffy::Diff.new(
        @action.job.node.files[@action.path].content,
        @action.content
      ).to_s(:color).split("\n").join("\n#{prefix}")
    elsif element == :approved
      string = @action.approved? ? "#{format :green} APPROVED" : "#{format :red} DECLINED"
      out "#{prefix} #{string} #{format}                                                 "
    elsif element.class == String
      out prefix + "#{element}"
    elsif checking
      out prefix + "#{@action.job.node.name}: #{checking}"
    elsif response
      out prefix + response.to_s.chomp.split("\n").join("\n#{prefix}")
    elsif element == :applied
      out prefix
      out "┣━\ #{format :green, :bold} #{@rbcm.actions.succeeded.count} secceeded #{format}"
      out "┣━\ #{format :red, :bold} #{@rbcm.actions.failed.count} failed #{format}" if @rbcm.actions.failed.any?
      out "┗━━──"
    else
    end
  end

  def out line
    # `tput cols`
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
    }.collect{ |key, val|
      val if params.include? key
    }.join
  end
end
