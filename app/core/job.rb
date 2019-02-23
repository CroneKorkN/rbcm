# contains parameters send to capabilities
# used to read configuration via "?"-suffix methods

class RBCM::Job
  def initialize rbcm:, type: :capability, name:, params: RBCM::Params.new, env:
    @status = :new
    @rbcm = rbcm
    @type = type
    @name = name
    @params = params
    @jobs = RBCM::JobList.new
    @definitions = RBCM::DefinitionList.new
    @env = {
      instance_variables: env[:instance_variables].dup, # local env
      class_variables:    env[:class_variables],
    }
  end

  attr_accessor :jobs, :env
  attr_reader :rbcm, :type, :name, :params, :status, :definitions

  def run
    raise "already done" if @status == :done
    puts "#{'  '*trace.count}#{self.class.name} RUN #{name}"
    # load capabilities
    if type == :file and @status == :new
      sandbox = RBCM::Project::Sandbox.dup
      sandbox.module_eval(File.read(name))
      sandbox.instance_methods.each do |name|
        puts "#{self.class.name} CAP #{name}"
        @definitions.append RBCM::Definition.new(
          type:    :capability,
          name:    name,
          content: sandbox.instance_method(name),
        )
      end
    end
    # perform job
    begin
      @context = RBCM::Context.new job: self
      result = @context.__run
      @status = :done
      #puts "#{self.class.name} RESULT #{result}"
      result
    rescue => e
      # if a definition contains a search, delay definition (rollback)
      # delayed jobs cant have return values
      puts "#{'  '*trace.count}#{self.class.name} DELAYED #{name} REASON #{e}"
      @status = :delayed
      :delayed_job
    end
  end
  
  def delay
  end
  
  def rollback
  end
  
  def stack
    [self, *anchestors]
  end
  
  def anchestors
    jobs.collect(&:anchestors).flatten
  end

  def trace
    RBCM::JobList.new [*parents, self]
  end

  def parent
    @rbcm.jobs.parent(self)
  end

  def parents
    RBCM::JobList.new [ 
      *@parent&.parents,
      @parent
    ].compact
  end
  
  def checks
    [ *stack.capability(:check),
      *stack.with(:check)
    ].collect{ |job|
      [job.hash, job.params[0] || job.params[:check]] # {"2l46h2lk": "ls /test"}
    }.to_h
  end
  
  def triggered_by
    [ stack.capability(:triggered_by).collect{|job| job.params[0]},
      stack.with(:triggered_by).collect{|job| job.params[:triggered_by]},
    ].flatten
  end
  
  def triggers
    [ stack.capability(:triggers).collect{|job| job.params[0]},
      stack.with(:triggers).collect{|job| job.params[:triggers]},
    ].flatten
  end
  
  def to_s
    to_str
  end
  
  def to_str
    type == :file ? name.split("/").last : name
  end
end
