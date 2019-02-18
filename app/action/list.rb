class RBCM::ActionList < Array
  def resolve actions=nil
    with actions || self do
      self.class.new [ 
        collect{|action| resolve(dependencies(action))},
        actions
      ].flatten.compact.uniq
    end
  end
  
  def dependencies action
    self.class.new collect{ |action|
      action.job.triggered_by.collect{ |triggered_by|
        find_all{|action| action.job.triggers.include? triggered_by}
      }
    }.flatten
  end
end
