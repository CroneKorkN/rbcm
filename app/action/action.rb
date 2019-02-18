class RBCM::Action
  def initialize job
    @job = job
    @node = @job.local_env[:node]
    @params = @job.params
    @blocker = RBCM::Blocker.new self
  end
  
  attr_reader :job, :node, :params, :blocker
end  
