# a hash which keys are initiated as arrays
# default values via RBCM::`Hash.new []` are inadequate for being volatile

class RBCM::ArrayHash < Hash
  def [] key
    store key, [] unless has_key? key
    super
  end
end
