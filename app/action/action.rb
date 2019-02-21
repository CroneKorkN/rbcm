class RBCM::Action
  def initialize node: node, job: job
    @job = job
    @node = node
    @params = @job.params
    @blocker = RBCM::Blocker.new self
  end
  
  attr_reader :job, :node, :params, :blocker
end  
