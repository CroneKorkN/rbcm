# holds a definition on form of a proc to be executed in a nodes sandbox

class Project::Definition
  def initialize type:, name:, content:
    @type, @name, @content = type, name, content
  end

  attr_reader :type, :name, :content

  def origin
    "#{type}:#{name}"
  end
end
