class Params
  attr_reader :ordered, :named

  def initialize ordered, named
    @ordered, @named = ordered, named
  end

  def [] key
    return ordered[key] if key.class == Integer
    return named[key] if key.class == Symbol
  end

  def []= key, value
    ordered[key] = value if key.class == Integer
    named[key] = value if key.class == Symbol
  end

  def to_s
    [ ordered.collect{ |param|
        "#{param}"
      },
      named.collect{ |k, v|
        "\e[2m\e[1m#{k}:\e[21m\e[22m #{v[0..60].to_s.gsub("\n"," \\ ")}#{"\e[2m\e[1m…\e[21m\e[22m" if v.length > 60}"
      }
    ].flatten(1).join("\e[2m\e[1m, \e[21m\e[22m")
  end

  def sendable
    [*ordered, named.any? ? named : nil].compact
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
    copy = self.dup
    [ids].flatten.each do |id|
      copy.ordered.delete id if id.class == Integer
      copy.named.delete id   if id.class == Symbol
    end
    return copy
  end
end
