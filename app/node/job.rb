# contains parameters send to capabilities
# used to read configuration via "?"-suffix methods

class Node::Job
  def initialize node:, capability:, params:
    @node = node
    @capability = capability
    @params = params
    @working_dir = working_dir
  end

  attr_reader :capability, :params, :node

  def to_s
    "#{@capability} #{@params}"
  end

  def project_file
    capability.project_file
  end
end
