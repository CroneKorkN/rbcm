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
    [ ordered.collect{ |param|
        "#{param}"
      },
      named.collect{ |k, v|
        "\e[2m\e[1m#{k}:\e[21m\e[22m #{v[0..40].to_s.gsub("\n"," \\ ")}#{"\e[2m\e[1m…\e[21m\e[22m" if v.length > 40}"
      }
    ].flatten(1).join("\e[2m\e[1m, \e[21m\e[22m")
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

  def delete *ids
    [ids].flatten.each do |id|
      ordered.delete id if id.class == Integer
      named.delete id if id.class == Symbol
    end
    return self
  end
end
