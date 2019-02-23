class RBCM::JobSearch < Array
  def [] name
    collect{|param| param[name]}
  end
  
  def [] key
    if key.class == Integer
      super
    else
      log warn: "warn: implicitly selected first: #{key}" if self.count > 1
      last[key]
    end
  end
end
