# holds a definition on form of a proc to be executed in a nodes sandbox

class Project::Definition
  def initialize type:, name:, content:, project_file:
    @type, @name, @content, @project_file = type, name, content, project_file
  end

  attr_reader :type, :name, :content, :project_file

  def origin
    "#{type}:#{name}"
  end

  def to_str
    @name
  end
end
