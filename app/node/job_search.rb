class RBCM::JobSearch < Array
  def [] name
    collect{|job| job.params[name]}
  end
end
