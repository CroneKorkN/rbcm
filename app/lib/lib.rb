def log notice, warning: nil, error: nil
  puts "┃\ \ \ \e[2m#{notice or warning or error}\e[0m"
end

# https://mrbrdo.wordpress.com/2013/02/27/ruby-with-statement/
module Kernel
  def with(object, &block)
    object.instance_eval &block
  end
end

class RBCM::Hash
  def << hash
    merge! hash
  end
end

class RBCM::Array
  def include_one? array
    (self & array).any?
  end

  # backport
  unless defined? append
    def append element
      self << element
    end
  end
end

class RBCM::Integer
  # backport
  unless defined? digits
    def digits
      self.to_s.chars.map(&:to_i)
    end
  end
end

# a hash which keys are initiated as arrays
# default values via RBCM::`Hash.new []` are inadequate for being volatile

class RBCM::ArrayHash < Hash
  def [] key
    store key, [] unless has_key? key
    super
  end
end
