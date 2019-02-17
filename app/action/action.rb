class RBCM::Action
  def initialize job, *params
    @job = job
    @params = params
  end
  
  attr_reader :job
end  
