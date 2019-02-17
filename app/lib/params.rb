class RBCM::Params
  attr_reader :ordered, :named, :block

  def initialize ordered, named={}, block=nil
    @ordered, @named, @block = ordered, named, block
  end
  
  attr_reader :block

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
        "#{param}".force_encoding(Encoding::UTF_8)
      },
      named.collect{ |k, v|
        "\e[2m\e[1m#{k}:\e[21m\e[22m #{v.to_s.force_encoding(Encoding::UTF_8)[0..54].gsub("\n"," \\ ")}#{"\e[2m\e[1m…\e[21m\e[22m" if v.to_s.length > 54}".force_encoding(Encoding::UTF_8)
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
