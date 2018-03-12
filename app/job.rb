class Job
  attr_accessor :capability
  attr_accessor :params
  attr_accessor :dependencies

  def initialize @node, @capability, @params, @dependencies
  end

  def ordered_params
    if named_params?
      params[0..-2]
    else
      params
    end
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
