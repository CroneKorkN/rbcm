# holds a definition on form of a proc to be executed in a nodes sandbox

class RBCM::Definition
  def initialize type:, name:, content:
    @type, @name, @content = type, name, content
  end

  attr_reader :type, :name, :content
  
  def path
    
  end
  
  def to_s
    "#{type}:#{type == :file ? name.split("/").last : name}"
  end
end
