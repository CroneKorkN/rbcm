def log notice, warning: nil, error: nil
  puts notice or warning or error
end

# https://mrbrdo.wordpress.com/2013/02/27/ruby-with-statement/
module Kernel
  def with(object, &block)
    object.instance_eval &block
  end
end

module Params
  def ordered_params
    named_params? ? @params[0..-2] : @params
  end

  def named_params
    @params.last if named_params?
  end

  def named_params?
    @params.last.class == Hash
  end
end

class Hash
  def << hash
    merge hash
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
    "_original_each".to_sym,
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
