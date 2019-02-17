class RBCM::Context
  def initialize definition: definition, job: job, env: env
    @env = env
    @job = job
    set_env
    define_singleton_method definition.name, definition.content
    send definition.name, job.params
  end
  
  # def definition
  #   Proc
  # end
  
  # catch
  def method_missing name, *ordered, **named, &block
    get_env
    job = Job.new name, Params.new(ordered, named, block), parent: @job
    @env.jobs.append job
    job.run @env
  end
  
  private
  
  def set_env
    @env[:instance_variables].each do |name, value|
      instance_variable_set :"@#{name}", value
    end
    @env[:class_variables].each do |name, value|
      class_variable_set :"@@#{name}", value
    end
  end

  def get_env
    instance_variables.each do |name|
      @env[:instance_variables][name[1..-1].to_sym] = instance_variable_get name
    end
    class_variables.each do |name|
      @env[:class_variables][name[2..-1].to_sym] = class_variable_get name
    end
  end
end
