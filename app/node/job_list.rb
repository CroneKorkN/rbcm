# holds a definition on form of a proc to be executed in a nodes sandbox

class RBCM::JobList < Array
  def capability query
    self.class.new find_all{|job| job.name == query.to_sym}
  end
  
  def with query
    return self unless query
    self.class.new find_all{|job| job.params[query]}
  end
end
