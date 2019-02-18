# contains parameters send to capabilities
# used to read configuration via "?"-suffix methods

class RBCM::Job
  attr_reader   :type, :name, :params, :done, :parent, :local_env

  def initialize type: :capability, name:, params: RBCM::Params.new, parent: nil
    @type = type
    @name = name
    @params = params
    @parent = parent
    @done = false
    @local_env
  end
  
  def run env
    return if @done
    @done = true
    @local_env = {
      node:               env[:node],
      rbcm:               env[:rbcm],
      instance_variables: env[:instance_variables].dup, # local_env
      class_variables:    env[:class_variables],
      jobs:               env[:jobs],
      checks:             env[:checks].dup, # local_env
    }
    @context = RBCM::Context.new(
      definition: env[:rbcm].definitions.type(@type).name(@name),
      job:        self,
      env:        @local_env,
    )
    return @context.__run
  end
  
  def stack
    RBCM::JobList.new [*parents, self]
  end
    
  def parents
    RBCM::JobList.new [ 
      *@parent&.parents,
      @parent
    ].compact
  end
  
  def [] name
    params[name]
  end
  
  def to_s
    name
  end
  
  def to_str
    name
  end
end
