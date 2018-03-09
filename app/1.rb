
class C
  def initialize
    load "f.rb"
    method = lambda(&method method_name)
    puts method.call
  end
end

C.new
