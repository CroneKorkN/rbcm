class RBCM::Unusable
  warn_level = $VERBOSE; $VERBOSE=nil
  instance_methods.each do |instance_method|
    undef_method instance_method
  end
  $VERBOSE = warn_level
  
  def method_missing *_
    raise "dont use this returned value"
  end
end
