class Action
  attr_reader   :node, :params, :triggered_by, :trigger, :chain, :dependencies,
                :capability, :obsolete
  attr_accessor :approved

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
    puts @trigger.any? ? " triggered: \e[30;46m\e[1m #{@trigger.compact.join(", ")} \e[0m" : ""
  end

  def apply
    response = @node.remote.execute(@line)
    puts self.to_s(response.exitstatus == 0 ? "\e[30;42m" : "\e[30;101m")
    puts @line if response.exitstatus != 0
    puts response.to_s.chomp
  end

  def to_s set_color=nil
    if set_color
      color = set_color
    elsif @obsolete
      color = "\e[30;42m"
    else
      color = "\e[30;43m"
    end
    "\e[1m#{color}  #{@chain.join(" > ")}  \e[0m  #{@params}"
  end
end
