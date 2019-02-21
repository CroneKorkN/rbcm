class RBCM::JobList < Array
  def capability query
    self.class.new find_all{|job| job.name == query.to_sym}
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
end
