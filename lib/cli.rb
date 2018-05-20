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
    puts "┗━━──"

    # finish
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
    action.approve! STDIN.gets.chomp.to_sym
    render :triggered if action.triggered.any?
  end

  def apply action
    @action = action
    response = action.apply!
    render :title, color: response.exitstatus == 0 ? :green : :red
    render :command if response.exitstatus != 0
    render response: response if response.length > 0
  end

  def render element=nil, section: nil, color: nil, first: false, response: nil, checking: nil
    if section
      puts "#{first ? nil : "┗━━──"}\n\n┏━━#{format :invert, :bold}#{" "*16}#{section}#{" "*16}#{format}━──\n┃"
    elsif element == :title
      triggerd_by = "#{format :trigger, :bold} #{@action.triggered_by.join(", ")} " if @action.triggered_by.any?
      puts "┣━\ #{triggerd_by}#{format color, :bold} #{@action.chain.join(" > ")} #{format}\ \ #{format :cyan}#{@action.job.params}#{format}"
    elsif element == :command
      puts "┃\ \ \ #{@action.line}\e[2m#{" UNLESS " if @action.check}#{@action.check}\e[0m"
    elsif element == :siblings
      puts "┃\ \ \ siblings: #{format :magenta}#{@action.siblings.each.node.each.name.join(", ")}#{format}"
    elsif element == :prompt
      print "┃\ \ \ APPROVE? #{"(" if @action.siblings.empty?}[a]ll#{")" if @action.siblings.empty?}, [y]es, [N]o > "
    elsif element == :diff
      puts "┃\ \ \ " + Diffy::Diff.new(
        @action.node.remote.files[@action.path],
        @action.node.files[@action.path]
      ).to_s(:color).split("\n").join("\n┃\ \ \ ")
    elsif checking
      puts "┃\ \ \ CHECKING #{checking}"
    elsif response
      puts "┃\ \ \ " + response.to_s.chomp.split("\n").join("\n┃\ \ \ ")
    elsif element == :triggered
      puts "┃\ \ \ triggered: \e[30;46m\e[1m #{@action.triggered.join(", ")} \e[0m; again: #{@action.trigger.-(@action.triggered).join(", ")}"
    else
    end
  end

  def format *params, **_
    "\e[0m" + {
      reset:   "\e[0m",
      bold:    "\e[1m",
      invert:  "\e[7m",
      trigger: "\e[30;46m",
      red:     "\e[30;41m",
      green:   "\e[30;42m",
      yellow:  "\e[30;43m",
      cyan:    "\e[36m",
      magenta: "\e[35m",
    }.select{ |key, _|
      params.include? key
    }.values.join
  end
end
