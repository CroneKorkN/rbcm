class RBCM::Action
  def initialize job, *params
    @job = job
    @params = params
  end
  
  def stack
    [@job, *@job.parents].reverse
  end
  
  attr_reader :job
end  
