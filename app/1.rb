
class C
  def initialize
    load "f.rb"
    function_name = "f"
    method = lambda(&method(function_name.to_sym))
    puts method.call
  end
end

C.new
