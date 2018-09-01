module RBCM::JobSearch
  def [] key
    if key.class == Integer
      super
    else
      log warn: "warn: implicitly selected first: #{key}" if self.count > 1
      last[key]
    end
  end
end
