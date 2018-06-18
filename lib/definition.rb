class Definition
  def initialize type:, name:, content:
    @type, @name, @content = type, name, content
  end

  attr_reader :type, :name, :content

  def origin
    "#{type}:#{name}"
  end
end
