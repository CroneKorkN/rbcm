class Action
  attr_accessor :approved
  attr_reader   :node, :triggered_by, :trigger, :chain, :dependencies,
                :capability, :obsolete, :job, :check, :triggered, :result,
                :source, :path

  def initialize job:, chain:, path: nil, params: nil, line: nil, check: nil,
                 dependencies: nil, trigger: nil, triggered_by: nil, source: nil
    @dependencies = [:file] + [dependencies].flatten - [chain.last]
    @trigger = [trigger, chain.last].flatten.compact
    @triggered_by = [triggered_by].flatten.compact
    @triggered = [];             @source = source
    @node = job.node;            @job = job;
    @chain = chain;              @capability = chain.last
    @obsolete = nil;             @approved = nil
    # command specific
    @line = line;                @check = check
    # file specific
    @path = path;                @params = params
  end

  def not_triggered
    return false if triggered_by.empty? or triggered_by.one? do |triggered_by|
      @node.triggered.flatten.include? triggered_by
    end
    true
  end

  def approve! input=:y
    if [:a, :y].include? input
      @node.files[@path] = content if self.class == FileAction
      @approved = true
      siblings.each.approve! if input == :a
      @node.triggered << @trigger
      @triggered = @trigger.compact - @node.triggered
    else
      @approved = false
    end
  end

  def succeeded
    @result.exitstatus == 0
  end

  def failed
    @result.exitstatus != 0
  end
end
