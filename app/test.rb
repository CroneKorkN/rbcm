module M
  def m
  end
  extend self
  #load "./f.rb"
  Dir['../config/capabilities/*.rb'].each {|path| load path}
  define_method(
    :ip?,
    Proc.new(&send(:method, :ip)) # using Proc prevents bind argument must be a subclass of Object (TypeError)
  )
  define_method(
    :m?,
    Proc.new(&send(:method, :m)) # using Proc prevents bind argument must be a subclass of Object (TypeError)
  )
  define_method :var do
    p self
    @a
  end
  #extend self
end

class C
  include M
  def initialize
    @a = 1
    m
    apt
    ip?
  end
end

p 2
pp C.instance_methods.sort

p C.new.var
