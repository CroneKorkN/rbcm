# contains parameters send to capabilities
# used to read configuration via "?"-suffix methods

class Node::Job
  attr_reader :capability, :params, :node

  def initialize node, capability, params
    @node = node
    @capability = capability
    @params = params
  end

  def to_s
    "#{@capability} #{@params}"
  end
end
