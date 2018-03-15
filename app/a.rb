module M
  def m
    "m"
  end
  #load "./f.rb"
  Dir['../config/capabilities/*.rb'].each {|path| load path}
  define_method(
    :ip?,
    Proc.new(&send(:method, :ip)) # using Proc prevents bind argument must be a subclass of Object (TypeError)
  )

  #extend self
end

class C
  include M
  def initialize
    define_singleton_method(
      "apt?".to_sym,
      method(:apt)
    )
    m
    apt
    apt?
    ip?
  end
end

p 2
pp C.instance_methods.sort

p C.new
