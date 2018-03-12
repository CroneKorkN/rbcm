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

  end

  def named_params
    @params.find_all do |param|
      param.class == "Hash"
    end
  end

  def run
    @node.send "__#{@capability}", *@params
  end
end
