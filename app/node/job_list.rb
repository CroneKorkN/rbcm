class RBCM::JobList < Array
  def capability query
    self.class.new find_all{|job| job.name == query.to_sym}
  end
  
  def with query
    return self unless query
    self.class.new find_all{|job| job.params[query]}
  end
end
