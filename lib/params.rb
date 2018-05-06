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

  def sendable
    [*ordered, named]
  end

  def empty?
    true if ordered.none? and named.none?
  end

  def first
    ordered[0]
  end

  def second
    ordered[1]
  end
end
