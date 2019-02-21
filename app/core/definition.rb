# holds a definition on form of a proc to be executed in a nodes sandbox

class RBCM::Definition
  def initialize type:, name:, content:, parent: nil
    @type, @name, @content, @parent = type, name, content, parent
  end

  attr_reader :type, :name, :content, :parent
  
  def to_s
    "#{type}:#{type == :file ? name.split("/").last : name}"
  end
end
