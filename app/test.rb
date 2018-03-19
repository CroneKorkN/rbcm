class C1
  def test1
    "test1"
  end
  def get
    Proc.new {test2}
  end
end

class C2
  def test2
    "test2"
  end
  def initialize
    p instance_eval &C1.new.get
  end
end

C2.new
