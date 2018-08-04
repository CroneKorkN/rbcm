class Action
  attr_accessor :approved, :applied
  attr_reader   :triggered_by, :trigger, :chain, :dependencies,
                :capability, :obsolete, :job, :check, :triggered, :result,
                :source, :path, :line, :state, :tags

  def initialize job:, path: nil, params: nil, line: nil, check: nil,
                 dependencies: nil, state:
    @dependencies = [:file] + [dependencies].flatten - [state[:chain].last]
    @triggered = [];
    @job = job
    @capability = job.capability
    @obsolete = nil;              @approved = nil
    # command specific
    @line = line;
    # file specific
    @path = path;                @params = params
    # extract state
    [:chain, :trigger, :triggered_by, :check, :source, :tags].each do |key|
      instance_variable_set "@#{key}", state[key]
    end
    @check = state[:check].last # WORKAROUND
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
      @job.node.triggered.flatten.include? triggered_by
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
      @job.node.files[@path].content = content if self.class == Action::File
      @approved = true
      siblings.each.approve! if input == :a
      @job.node.triggered << @trigger
      @triggered = @trigger.compact - @job.node.triggered
    else
      @approved = false
    end
  end
end
