module M
  load "./f.rb"
end

class C
  include M
  public :f  
end

C.new.f
