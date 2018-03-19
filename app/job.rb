class Job < Capabilities
  attr_reader :capability, :params

  def initialize capability, params
    @capability = capability
    @params = params
    @dependency_cache = []
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
    @node = node
    @commands = []
    self.send @capability, *@params
    return @commands
  end
end
