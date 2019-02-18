class RBCM::Blocker
  def initialize action
    @action = action
    @reasons = nil
  end
  
  def reasons
    @reasons ||= [*triggered_by, *check].compact
  end
  
  def triggered_by
    if delta = @action.job.triggered_by - @action.node.cache[:triggered] 
      delta.collect{|trigger| "trigger_missing:#{trigger}"}
    end
  end
  
  def check 
    "checks:successfull" if @action.job.checks.collect{ |id, line|
      @action.node.cache[:checks][id] ||= \
        @action.node.remote.execute(line).exitstatus == 0
    }.all?
  end
end
