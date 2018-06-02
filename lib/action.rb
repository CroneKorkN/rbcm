class Action
  attr_accessor :approved, :applied
  attr_reader   :node, :triggered_by, :trigger, :chain, :dependencies,
                :capability, :obsolete, :job, :check, :triggered, :result,
                :source, :path, :tags, :origin

  def initialize job:, chain:, path: nil, params: nil, line: nil, check: nil,
                 dependencies: nil, trigger: nil, triggered_by: nil,
                 source: nil, tags: nil, origin: nil
    @dependencies = [:file] + [dependencies].flatten - [chain.last]
    @trigger = [trigger, chain.last].flatten.compact
    @triggered_by = [triggered_by].flatten.compact
    @triggered = [];              @source = source
    @node = job.node;             @job = job
    @chain = chain;               @capability = chain.last
    @obsolete = nil;              @approved = nil
    @tags = tags.compact.flatten; @origin = origin
    # command specific
    @line = line;                @check = check
    # file specific
    @path = path;                @params = params
  end

  def neccessary?
    check!
    not obsolete
  end

  def approved?
    @approved
  end

  def approvable?
    neccessary? and triggered? and approved? == nil
  end

  def applyable?
    approved? and not applied?
  end

  def triggered?
    triggered_by.empty? or triggered_by.one? do |triggered_by|
      @node.triggered.flatten.include? triggered_by
    end
  end

  def applied?
    @applied
  end

  def succeeded?
    pp self.chain unless @result
    @result.exitstatus == 0
  end

  def failed?
    @result.exitstatus != 0
  end

  def approve! input=:y
    if [:a, :y].include? input
      @node.files[@path] = content if self.class == Action::File
      @approved = true
      siblings.each.approve! if input == :a
      @node.triggered << @trigger
      @triggered = @trigger.compact - @node.triggered
    else
      @approved = false
    end
  end
end
