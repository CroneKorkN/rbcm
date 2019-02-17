# holds a definition on form of a proc to be executed in a nodes sandbox

class RBCM::Definition
  def initialize type:, name:, content:, project_file:
    @type, @name, @content, @project_file = type, name, content, project_file
  end

  attr_reader :type, :name, :content, :project_file
  
  def to_str
    "#{type}:#{name}"
  end
end
