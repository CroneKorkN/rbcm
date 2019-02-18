class RBCM::JobSearch < Array
  def [] name
    collect{|job| params[name]}
  end
end
