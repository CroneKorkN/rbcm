# contains parameters send to capabilities
# used to read configuration via "?"-suffix methods

class RBCM::Job
  attr_reader :type, :name, :params, :done

  def initialize type: :capability, name:, params:, parent: false
    @type = type
    @name = name
    @block = block
    @parent = parent
    @done = false
  end
  
  def run env
    return if @done
    @context = RBCM::Context.new(
      definition: env.project.definitions.type(job.type).name(job.name),
      job:        job,
      env:        @env,
    )
    @done = true
  end
  
  def definition
    definition = 
  end

  def to_s
    "#{@capability} #{@params}"
  end
end
