class RBCM::Target
  def initialize node:, name:
    @node = node
    @name = name
  end
  
  def triggered?
    
  end
  
  def triggers
    [ @node.actions.select{|action| action.job.triggers.include? @name},
      @node.actions.select{|action| action.job.params[:trigger]},
    ].flatten
  end
  
  def triggered_by
    [ @node.actions.select{|action| action.job.triggered_by.include? @name},
      #@node.actions.select{|action| action.jobtriggered_by == },
    ].flatten
  end
end
