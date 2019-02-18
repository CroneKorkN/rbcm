class RBCM::Blocker
  def initialize action
    @action = action
    @reasons = nil
  end
  
  def reasons
    @reasons ||= [*triggered_by, *check].compact
  end
  
  def triggered_by
    [ *@action.job.stack.capability(:triggered_by).collect{|job| job.params[0]},
      *@action.job.stack.with(:triggered_by).collect{|job| job.params[:triggered_by]},
    ].collect{ |triggered_by| 
      if not @action.node.cache[:triggered].include? triggered_by
        "triggered_by:#{triggered_by}"
      end
    }
  end
  
  def check
    "checks:successfull" if [ 
      *@action.job.stack.capability(:check),
      *@action.job.stack.with(:check)
    ].collect{ |job|
      check = job.params[:check] || job.params[0]
      if @action.node.cache[:checks][job.hash] != false
        result = @action.node.remote.execute(job.params[0]).exitstatus == 0
        @action.node.cache[:checks][job.hash] = result
      end
      @action.node.cache[:checks][job.hash]
    }.all?
  end
end
