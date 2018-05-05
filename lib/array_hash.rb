# a hash which keys are initiated as arrays

class ArrayHash < Hash
  def [] key
    store key, [] unless has_key? key
    super
  end
end
