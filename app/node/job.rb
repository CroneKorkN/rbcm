# contains parameters send to capabilities
# used to read configuration via "?"-suffix methods

class RBCM::Job
  attr_reader :type, :name, :params, :done, :parent

  def initialize type: :capability, name:, params: RBCM::Params.new(ordered: []), parent: nil
    @type = type
    @name = name
    @params = params
    @parent = parent
    @done = false
  end
  
  def run env
    return if @done
    @context = RBCM::Context.new(
      definition: env[:rbcm].definitions.type(@type).name(@name),
      job:        self,
      env:        env,
    )
    @done = true
    @context.__run
  end
  
  def parents
    [ @parent,
      @parent&.parents
    ].flatten.compact
  end
  
  def to_s
    name
  end
end
