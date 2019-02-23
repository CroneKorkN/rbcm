class RBCM::JobList < Array
  def pending
    self.class.new [*status(:new), *status(:delayed)]
  end
  
  def capability query
    self.class.new find_all{|job| job.name.to_sym == query.to_sym}
  end
  
  def scope query
    self.class.new capability(query).last.stack
  end
  
  def with query
    return self unless query
    self.class.new find_all{|job| job.params[query]}
  end
  
  def status query
    self.class.new find_all{|job| job.status == query}
  end
  
  def childless
    self.class.new select{|job| none?{|other| other.parent == job}}
  end
  
  def parent child
    find{|job| job.jobs.include? child}
  end
  
  def node_names
    capability(:node).collect{|j| j.params.first}.uniq
  end
end
