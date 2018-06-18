class Capability
  def initialize name:, content:
    @name = name
    @content = content
    @type = type
  end

  attr_reader :name, :content

  def type
    @name[-1] == "!" ? :regular : :final
  end
end
