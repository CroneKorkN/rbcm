class Params < Array
  attr_reader :ordered, :named

  def initialize ordered, named
    @ordered, @named = ordered, named
  end
end
