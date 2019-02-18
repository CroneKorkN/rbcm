class RBCM::Context
  def initialize definition:, job:, env:
    puts "===== #{self.class.name} #{job.name}" 
    @definition = definition
    @env = env
    @job = job
    @env[:instance_variables].each do |name, value|
      instance_variable_set :"@#{name}", value
    end
    define_singleton_method definition.name, definition.content
  end
  
  def __run
    if @definition.content.parameters.any?
      send @definition.name, *@job.params.sendable, &@job.params.block
    else
      send @definition.name, &@job.params.block
    end
  end
  
  # def definition ...
  #   Proc
  # end
  
  # catch
  def method_missing name, *ordered, **named, &block
    raise unless @env[:rbcm].definitions.type(@job.type).name(@job.name)
    instance_variables.select{|name| not [:"@env", :"@job", :"@definition"].include? name}.each do |name|
      @env[:instance_variables][name[1..-1].to_sym] = instance_variable_get name
    end
    job = RBCM::Job.new(
      name: name, 
      params: RBCM::Params.new(ordered, named, block), 
      parent: @job
    )
    puts job.name
    @env[:jobs].append job
    job.run @env
  end
end
