class Action
  attr_accessor :approved
  attr_reader   :node, :triggered_by, :trigger, :chain, :dependencies,
                :capability, :obsolete, :job, :check, :triggered, :result

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
    @triggered = []
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
    return true
  end

  def approve! input=:y
    if [:a, :y].include? input.to_sym
      @approved = true
      siblings.each.approve! if input == :a
      @node.triggered << @trigger
      @triggered = @trigger.compact - @node.triggered
    else
      @approved = false
    end
  end
end
