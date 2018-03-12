class Job
  attr_accessor :capability
  attr_accessor :params

  def initialize node, capability, params
    @node = node
    @capability = capability
    @params = params
  end

  def ordered_params
    named_params? ? params[0..-2] : params
  end

  def named_params
    params.last if named_params?
  end

  def named_params?
    params.last.class == Hash
  end

  def run
    @node.capability_cache = @capability
    @node.send "__#{@capability}", *@params
    @node.capability_cache = nil
  end
end
