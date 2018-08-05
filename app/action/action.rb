class Action
  attr_accessor :approved, :applied
  attr_reader   :triggered_by, :trigger, :chain, :dependencies,
                :obsolete, :job, :check, :triggered, :result,
                :source, :path, :line, :state, :tags

  def initialize job:, params: nil, line: nil, check: nil,
                 dependencies: nil, state:
    @job = job
    @triggered = []
    @obsolete = nil
    @approved = nil
    # command specific
    @line = line
    # file specific
    @params = params
    @path = params.first if job.capability.name == :file
    # extract state
    [:chain, :trigger, :triggered_by, :check, :source, :tags, :working_dirs].each do |key|
      instance_variable_set "@#{key}", state[key]
    end
    @working_dir = @working_dirs.last
    @dependencies = [:file] + [dependencies].flatten - [@chain.last]
  end

  def project_file
    @chain.reverse.find{ |element|
      defined?(element.project_file) and element.project_file
    }.project_file
  end

  def checkable?
    @check.any? or self.class == Action::File
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
