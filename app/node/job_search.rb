module RBCM::JobSearch
  def [] key
    if key.class == Integer
      super
    else
      log warn: "warn: implicitly selected first: #{key}" if self.count > 1
      fetch(0)[key]
    end
  end
end
