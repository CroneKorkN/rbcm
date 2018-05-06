class Params
  attr_reader :ordered, :named

  def initialize ordered, named
    @ordered, @named = ordered, named
  end

  def [] id
    return ordered[id] if id.class == Integer
    return named[id] if id.class == Symbol
  end

  def to_s
    [ordered, named.collect{|k,v| "#{k}: #{v}"}].join(', ')
  end
end
