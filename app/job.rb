class Job
  attr_accessor :capability
  attr_accessor :params
  attr_accessor :dependencies

  def initialize node, capability, params, dependencies
    @node = node
    @capability = capability
    @params = params
    @dependencies = dependencies
  end

  def ordered_params
    params.pop
  end

  def named_params
    params.last
  end

  def run
    @node.capability_cache = @capability
    @node.send "__#{@capability}", *@params
    @node.capability_cache = nil
  end
end
