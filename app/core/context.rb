class RBCM::Context
  def initialize job:
    @job = job
    set_env
    if @job.definition.type != :file
      define_singleton_method :__abstract, 
        @job.definition.content
    end
  end
  
  def __run
    puts "#{'  '*@job.trace.count}#{self.class.name} RUN #{@job.name} PARAMS #{@job.params.sendable}"
    if @job.type == :file
      instance_eval File.read(@job.name)
    else
      send :__abstract, *@job.params.delete(
        :triggers, :triggered_by, :tag
      ).sendable do
        instance_eval &@job.params.block
      end
    end
  end
  
  # def definition *params
  #   Proc
  # end
  
  # catch
  def method_missing name, *ordered, **named, &block
    puts "#{'  '*@job.trace.count}#{self.class.name} JOB #{name} #{ordered} #{named}"
    params = RBCM::Params.new(ordered, named, block)
    if name.to_s.end_with? '?'
      # search
      return RBCM::JobSearch.new \
        @job.scope(:node).capability(name.to_s[0..-2].to_sym).with(ordered.first).collect(&:params)
    else
      # run
      # break unless called method has definition available
      super name unless @job.rbcm.definitions.name(name)
      # collect env
      get_env
      # create job
      job = RBCM::Job.new(
        rbcm: @job.rbcm,
        name: name, 
        params: params,
        env: @job.env
      )
      # save job
      @job.jobs.append job
      # run job
      return job.run
    end
  end
  
  private
  
  def get_env
    @job.env[:instance_variables].each do |name, value|
      instance_variable_set :"@#{name}", value
    end
    @job.env[:class_variables].each do |name, value|
      self.class.class_variable_set :"@@#{name}", value
    end
  end
  
  def set_env
    instance_variables.select{|name| not :"@job" == name}.each do |name|
      @job.env[:instance_variables][name[1..-1].to_sym] = instance_variable_get name
    end
    self.class.class_variables.each do |name|
      @job.env[:class_variables][name[2..-1].to_sym] = self.class.class_variable_get :"@@#{name}"
    end
  end
end
