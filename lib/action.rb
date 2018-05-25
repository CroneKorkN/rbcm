class Action
  attr_accessor :approved
  attr_reader   :node, :triggered_by, :trigger, :chain, :dependencies,
                :capability, :obsolete, :job, :check, :triggered, :result

  def initialize job:, path: nil, params: nil, line: nil, dependencies: nil,
                 check: nil, chain:, trigger: nil, triggered_by: nil
    @dependencies = [:file] + [dependencies].flatten - [chain.last]
    @trigger = [trigger, chain.last].flatten.compact
    @triggered_by = [triggered_by].flatten.compact
    @triggered = []
    @node = job.node;            @job = job;
    @chain = chain;              @capability = chain.last
    @obsolete = nil;             @approved = nil
    # command specific
    @line = line;                @check = check
    # file specific
    @path = path;                @params = params
  end

  def not_triggered
    return false if triggered_by.empty?
    return false if triggered_by.one? do |triggered_by|
      @node.triggered.flatten.include? triggered_by
    end
    return true
  end

  def approve! input=:y
    if [:a, :y].include? input
      @approved = true
      siblings.each.approve! if input == :a
      @node.triggered << @trigger
      @triggered = @trigger.compact - @node.triggered
    else
      @approved = false
    end
  end
end
