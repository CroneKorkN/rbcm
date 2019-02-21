class RBCM::Context
  def initialize definition:, job:, env:
    @definition = definition
    @env = env
    @job = job
    @env[:instance_variables].each do |name, value|
      instance_variable_set :"@#{name}", value
    end
    @env[:class_variables].each do |name, value|
      self.class.class_variable_set :"@@#{name}", value
    end
    if definition.type != :file
      define_singleton_method :abstract, @definition.content
    end
  end
  
  def __run
    puts "#{self.class.name} RUN #{@job.name} PARAMS #{@job.params.sendable}"
    if @definition.type == :file
      instance_eval File.read(@definition.name)
    else
      send :abstract, *@job.params.sendable do
        instance_eval &@job.params.block
      end
    end
  end
  
  # def definition ...
  #   Proc
  # end
  
  # catch
  def method_missing name, *ordered, **named, &block
    puts "#{self.class.name} JOB #{name} #{ordered} #{named}"
    params = RBCM::Params.new(ordered, named, block)
    if name.to_s.end_with? '?'
      return RBCM::JobSearch.new @env[:jobs].capability(name.to_s[0..-2].to_sym).with(ordered.first).collect(&:params)
    else
      # check if called method has definition available
      raise "capability not found: #{name}" unless @env[:rbcm].definitions.name(name)
      # collect env
      instance_variables.select{|name| not [:"@env", :"@job", :"@definition"].include? name}.each do |name|
        @env[:instance_variables][name[1..-1].to_sym] = instance_variable_get name
      end
      self.class.class_variables.each do |name|
        @env[:class_variables][name[2..-1].to_sym] = self.class.class_variable_get :"@@#{name}"
      end
      # create job
      job = RBCM::Job.new(
        name: name, 
        params: params,
        parent: @job
      )
      # save job
      @env[:jobs].append job
      # run job
      return job.run @env
    end
  end
  
  # def singleton_method_added name
  #   puts "#{self} CAP #{name}"
  #   @env[:definitions].append RBCM::Definition.new(
  #     type:    :capability,
  #     name:    name,
  #     content: method(name)
  #   )
  #   # TODO undef method
  # end
end
