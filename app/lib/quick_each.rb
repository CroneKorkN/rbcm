#
# quickeach
#

class RBCM::QuickEach
  def initialize enumerable
    @enumerable = enumerable
  end
  def method_missing method, *args, &block
    @enumerable.collect do |element|
      element.send method, *args, &block
    end
  end
end

class RBCM::Array
  # copy method
  define_method(
    :_original_each,
    instance_method(:each)
  )

  def each &block
    unless block_given?
      return RBCM::QuickEach.new self
    else
      _original_each &block
    end
  end
end

#
# quickselect
#

class RBCM::QuickSelect
  def initialize enumerable
    @enumerable = enumerable
  end
  def method_missing method, *args, &block
    @enumerable.select do |element|
      element.send(method, *args, &block) == true
    end
  end
end

class RBCM::Array
  # copy method
  define_method(
    :_original_select,
    instance_method(:select)
  )

  def select &block
    unless block_given?
      return RBCM::QuickSelect.new self
    else
      _original_select &block
    end
  end
end
