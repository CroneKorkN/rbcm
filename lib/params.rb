class Params
  def initialize params
    @params = params || []
  end

  def first
    ordered.first
  end

  def ordered
    named? ? @params[0..-2] : @params
  end

  def named
    named? ? @params.last : {}
  end

  def ordered?
    ordered.any?
  end

  def named?
    @params.last.class == Hash
  end

  def any?
    empty? == false
  end

  def empty?
    ordered.empty? and named.empty?
  end

  def to_s
    [ ordered.join,
      named.collect{|k, v| "#{k}: #{v}"}
    ].flatten(1).join(', ')
  end
end
