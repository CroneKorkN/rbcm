class RBCM::JobSearch < Array
  def [] key
    if key.class == Integer
      super
    else
      log warn: "warn: implicitly select first: #{key}" if self.count > 1
      fetch(-1)[key]
    end
  end
end
