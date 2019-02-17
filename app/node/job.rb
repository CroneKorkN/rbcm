# contains parameters send to capabilities
# used to read configuration via "?"-suffix methods

class RBCM::Job
  attr_reader :type, :name, :params, :done

  def initialize type: :capability, name:, params: RBCM::Params.new(ordered: [1]), parent: false
    @type = type
    @name = name
    @params = params
    @parent = parent
    @done = false
  end
  
  def run env
    puts "======== #{self.class.name} #{self.hash}"
    puts "#{@type} #{@name}"
    return if @done
    @context = RBCM::Context.new(
      definition: env.rbcm.definitions.type(@type).name(@name),
      job:        self,
      env:        env,
    )
    @done = true
  end
  
  def to_s
    "#{@capability} #{@params}"
  end
end
