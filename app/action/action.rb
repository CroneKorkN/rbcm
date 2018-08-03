class Action
  attr_accessor :approved, :applied
  attr_reader   :node, :triggered_by, :trigger, :chain, :dependencies,
                :capability, :obsolete, :job, :check, :triggered, :result,
                :source, :path, :tags, :line

  def initialize job:, path: nil, params: nil, line: nil, check: nil,
                 dependencies: nil, node:, state:
    @dependencies = [:file] + [dependencies].flatten - [state[:chain].last]
    @trigger = [state[:trigger], state[:chain].last].flatten.compact
    @triggered_by = [state[:triggered_by]].flatten.compact
    @triggered = [];              @source = state[:source]
    @node = node;                 @job = job
    @chain = state[:chain];       @capability = state[:chain].last
    @obsolete = nil;              @approved = nil
    @tags = state[:tag].compact.flatten
    # command specific
    @line = line;                @check = state[:check].last
    # file specific
    @path = path;                @params = params
  end

  def checkable?
    @check or self.class == Action::File
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
    triggered_by.empty? or triggered_by.one?{ |triggered_by|
      @node.triggered.flatten.include? triggered_by
    }
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
      @node.files[@path].content = content if self.class == Action::File
      @approved = true
      siblings.each.approve! if input == :a
      @node.triggered << @trigger
      @triggered = @trigger.compact - @node.triggered
    else
      @approved = false
    end
  end
end
