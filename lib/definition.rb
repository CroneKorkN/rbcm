class Definition
  attr_reader :content, :origin
  def initialize content, origin: nil
    @content, @origin = content, origin
  end
end
