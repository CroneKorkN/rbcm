class RBCM::Context
  def initialize definition:, job:, env:
    puts "======== #{self.class.name} #{self.hash}"
    @definition = definition
    @env = env
    @job = job
    set_env
    define_singleton_method definition.name, definition.content
    if definition.content.parameters.any?
      send definition.name, *job.params.sendable
    else
      send definition.name
    end
  end
  
  # def definition
  #   Proc
  # end
  
  # catch
  def method_missing name, *ordered, **named, &block
    raise unless @env.rbcm.definitions.type(@job.type).name(@job.name)
    get_env
    job = RBCM::Job.new(
      name: name, 
      params: RBCM::Params.new(ordered, named, block), 
      parent: @job
    )
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
    instance_variables.select{|name| not [:"@env", :"@job", :"@definition"].include? name}.each do |name|
      @env[:instance_variables][name[1..-1].to_sym] = instance_variable_get name
    end
    # class_variables.each do |name|
    #   @env[:class_variables][name[2..-1].to_sym] = class_variable_get name
    # end
  end
end
