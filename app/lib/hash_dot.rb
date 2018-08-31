class Hash
  def method_missing name, *ordered, **named, &block
    fetch name
  end
end
