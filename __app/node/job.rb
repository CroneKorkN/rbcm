# contains parameters send to capabilities
# used to read configuration via "?"-suffix methods

class RBCM::Node::Job
  attr_reader :capability, :params, :node
  attr_accessor :jobs

  def initialize node:, capability:, params:
    @node = node
    @capability = capability
    @params = params
    @jobs = []
  end
  
  def call
    
  end

  def to_s
    "#{@capability} #{@params}"
  end
end
