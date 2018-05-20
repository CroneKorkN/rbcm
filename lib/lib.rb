def log notice, warning: nil, error: nil
  puts "\e[2m#{notice or warning or error}\e[0m"
end

# https://mrbrdo.wordpress.com/2013/02/27/ruby-with-statement/
module Kernel
  def with(object, &block)
    object.instance_eval &block
  end
end


class Hash
  def << hash
    merge! hash
  end
end

class Array
  def include_one? array
    (self & array).any?
  end
end

#
# quickeach
#

class QuickEach
  def initialize enumerable
    @enumerable = enumerable
  end
  def method_missing method, *args, &block
    @enumerable.collect do |element|
      element.send method, *args, &block
    end
  end
end

class Array
  # copy method
  define_method(
    :_original_each,
    instance_method(:each)
  )

  def each &block
    unless block_given?
      return QuickEach.new self
    else
      _original_each &block
    end
  end
end

#
# quickselect
#

class QuickSelect
  def initialize enumerable
    @enumerable = enumerable
  end
  def method_missing method, *args, &block
    @enumerable.select do |element|
      element.send(method, *args, &block) == true
    end
  end
end

class Array
  # copy method
  define_method(
    :_original_select,
    instance_method(:select)
  )

  def select &block
    unless block_given?
      return QuickSelect.new self
    else
      _original_select &block
    end
  end
end
