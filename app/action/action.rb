class RBCM::Action
  def initialize node:, job:
    @job = job
    @node = node
    @params = @job.params
    @blocker = RBCM::Blocker.new self
  end

  attr_reader :job, :node, :params, :blocker
  
  def checks
    @checks ||= [ *@job.trace.capability(:check).collect{|job| job.params.first}, 
      *@job.trace.with(:check).collect{|job| job.params[:check]},
    ].collect{|command| RBCM::Check.new @node, command}
  end
end  
