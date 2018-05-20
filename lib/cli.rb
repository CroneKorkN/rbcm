class CLI
  def initialize core, params
    # parse
    options = Options.new params
    puts "\n================ RBCM starting ================\n\n"
    core.parse

    # check
    puts "\n================ CHECKING #{core.nodes.count} nodes ================\n\n"
    core.actions.each.check

    # approve
    puts "\n================ APPROVING #{core.actions.select{|a| a.obsolete == false}.count} actions ================\n\n"
    core.actions.extend(ActionList).resolve_triggers.each.approve

    # apply
    core.apply
  end

  def check action

  end

  def approve action
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
end
