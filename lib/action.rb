class Action
  attr_reader :line, :params, :dependencies, :obsolete,
    :approved, :triggered_by, :chain, :capability, :node, :trigger
  attr_writer :approved

  def initialize node:, line:, params:, dependencies:,
      check: nil, chain:, trigger: nil, triggered_by: nil
    @chain = chain
    @capability = chain.last
    @node = node
    @line = line
    @params = params
    @dependencies = [:file] + [dependencies].flatten - [chain.last]
    @check = check
    @obsolete = nil
    @approved = nil
    @trigger = trigger + [chain.last]
    @triggered_by = triggered_by
  end

  def siblings
    @node.rbcm.commands.select{ |command|
      command.chain[1..-1] == @chain[1..-1] and command.line == @line
    } - [self]
  end

  def check
    log "CHECKING $>_ #{@check}"
    path = @params[0]
    if @capability == :file
      if params[:template]
        content = Template.new(
          @node.rbcm.project_path, params[:template]
        ).render
      else
        content = params[:content]
      end
      @node.files[path] = content
      @obsolete = @node.remote.files[path].chomp == @node.files[path].chomp
    elsif @check
      @obsolete = @node.remote.execute(@check).exitstatus == 0
    else
      @obsolete = false
    end
  end

  def not_triggered
    return false if triggered_by.empty?
    return false if triggered_by.one?{|triggered_by| @node.triggered.flatten.include? triggered_by}
    log "NOT TRIGGERED"
    return true
  end

  def approve
    # check if neccessary
    check unless [true, false].include? @obsolete
    # print info
    puts self.to_s
    puts diff unless @capability == :file
    # finish if obsolete
    return if @obsolete or @approved or not_triggered
    puts diff if @capability == :file
    # interact
    print "APROVE (#{"g," if siblings.any?}y,N): " # o: apply to ahole group
    input = STDIN.gets.chomp.to_sym
    @approved = [:g, :y].include? input
    siblings.each.approved = true if input == :g
    @node.triggered << @trigger
    puts @trigger.any? ? " triggered: \e[30;46m\e[1m #{@trigger.join(", ")} \e[0m" : ""
  end

  def apply
    response = @node.remote.execute(@line)
    puts self.to_s(response.exitstatus == 0 ? "\e[30;42m" : "\e[30;101m")
    puts @line if response.exitstatus != 0
    puts response.to_s.chomp
  end

  def diff
    if @capability == :file
      path = @params[0]
      return @diff ||= Diffy::Diff.new(
        @node.remote.files[path],
        @node.files[path]
      ).to_s(:color)
    else
      "  $>_ \e[1m#{@line}\e[0m\e[2m#{" CHECK " if @check}#{@check}\e[0m"
    end
  end

  def to_s set_color=nil
    if set_color
      color = set_color
    elsif @obsolete
      color = "\e[30;42m"
    else
      color = "\e[30;43m"
    end
    [ "\n\e[1m#{color}  #{@chain.join(" > ")}  \e[0m  #{@params}\e[0m",
      siblings.any? ? "\n\ \ siblings: #{siblings.each.node.each.name.join(", ")}" : "",
    ].join
  end
end
