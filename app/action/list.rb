class RBCM::ActionList < Array
  def resolve actions=nil
    with actions || self do
      self.class.new [ 
        collect{|action| resolve(dependencies(action))},
        self
      ].flatten.compact.uniq
    end
  end
  
  def dependencies depending
    self.class.new find_all{ |dependency|
      dependency.job.triggers.one?{ |triggers|
        depending.job.triggered_by.include? triggers
      }
    }.flatten.compact
  end
end
