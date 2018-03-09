
class C
  def initialize
    load "f.rb"
    function_name = "f"
    method = lambda(&method(function_name.to_sym))
    self.define_singleton_method function_name, &method
  end
end

C.new.f
