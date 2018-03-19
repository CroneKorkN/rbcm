class Job < Capabilities
  attr_reader :capability, :params

  def initialize capability, params
    @capability = capability
    @params = params
    @dependency_cache = []
    define_getters
  end

  def ordered_params
    named_params? ? @params[0..-2] : @params
  end

  def named_params
    @params.last if named_params?
  end

  def named_params?
    @params.last.class == Hash
  end

  def commands node
    p apt?

    @node = node
    @commands = []
    self.send @capability, *@params
    @commands
  end
end
