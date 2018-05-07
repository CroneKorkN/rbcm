class Action
  attr_accessor :approved
  attr_reader   :node, :triggered_by, :trigger, :chain, :dependencies,
                :capability, :obsolete, :job

  def initialize node:, path: nil, params: nil, line: nil, dependencies: nil,
      check: nil, chain:, trigger: nil, triggered_by: nil, job:
    @chain = chain
    @capability = chain.last
    @node = node
    @dependencies = [:file] + [dependencies].flatten - [chain.last]
    @obsolete = nil
    @approved = nil
    @trigger = [trigger, chain.last].flatten.compact
    @triggered_by = [triggered_by].flatten.compact
    @job = job
    # command specific
    @line = line
    @check = check
    # file specific
    @path = path
    @params = params
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
    puts "  siblings: #{siblings.each.node.each.name.join(", ")}" if siblings.any?
    print "APROVE (#{"g," if siblings.any?}y,N): " # o: apply to ahole group
    input = STDIN.gets.chomp.to_sym
    @approved = [:g, :y].include? input
    siblings.each.approved = true if input == :g
    @node.triggered << @trigger
    if (triggered = @trigger.compact - @node.triggered).any?
      puts " triggered: \e[30;46m\e[1m #{triggered.join(", ")} \e[0m; again: #{@trigger.-(triggered).join(", ")}"
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
    [ "#{"\e[30;46m\e[1m  #{triggered_by.join(", ")}  \e[0m" if triggered_by.any?}",
      "\e[1m#{color}  #{@chain.join(" > ")} \e[0m\e[96m #{@job.params}  \e[0m"
    ].join
  end

  def apply response
    puts self.to_s(response.exitstatus == 0 ? "\e[30;42m" : "\e[30;101m")
    puts "  $>_ #{@line}" if response.exitstatus != 0
    puts response.to_s.chomp if response.length > 0
  end
end
