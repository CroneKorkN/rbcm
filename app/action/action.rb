class RBCM::Action
  def initialize job
    @job = job
    @blocker = RBCM::Blocker.new self
  end

  attr_reader :job, :blocker
  
  def node
    @job.local_env[:node]
  end
  
  def params
    @job.params
  end
end  
