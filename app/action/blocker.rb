class RBCM::Blocker
  def initialize action
    @action = action
    @reasons = nil
  end
  
  def reasons
    @reasons ||= [*triggered_by, *checks]
  end
  
  def triggered_by
    [ *@action.job.stack.capability(:triggered_by).collect{|job| job.params[0]},
      *@action.job.stack.with(:triggered_by).collect{|job| job.params[:triggered_by]},
    ].collect{ |triggered_by| 
      "triggered_by:#{triggered_by}" if not @action.node.triggered.include? triggered_by
    }
  end
  
  def checks
    @action.job.stack.capability(:check).collect do |job|
      execute = ->{node.remote.execute(job.params[:check]).exitstatus == 0}
      "check:#{job.check}" if not node.checks[job.hash] ||= execute.call
    end
  end
end
