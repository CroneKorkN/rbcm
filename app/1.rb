
class C
  def self.init
    cached_methods = private_methods
    p private_methods.sort.count
    load "f.rb"
    f
    p private_methods.sort.count
    p function_name = (private_methods - cached_methods).first.to_sym
    p
    method = lambda(&method(function_name.to_sym))
    self.define_method function_name, &method
  end
end

C.init

C.new.f
