# contains parameters send to capabilities
# used to read configuration via "?"-suffix methods

class RBCM::Job
  attr_reader :type, :name, :params, :done, :parent

  def initialize type: :capability, name:, params: RBCM::Params.new, parent: nil
    @type = type
    @name = name
    @params = params
    @parent = parent
    @done = false
  end
  
  def run env
    return if @done
    @done = true
    @context = RBCM::Context.new(
      definition: env[:rbcm].definitions.type(@type).name(@name),
      job:        self,
      env:        env,
    )
    return @context.__run
  end
  
  def stack
    [*parents, self]
  end
    
  def parents
    [ *@parent&.parents,
      @parent
    ].compact
  end
  
  def to_s
    name
  end
  
  def to_str
    name
  end
end
