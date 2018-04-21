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
