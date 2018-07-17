# holds a definition on form of a proc to be executed in a nodes sandbox

class Project::Definition
  def initialize type:, name:, content:, path:
    @type, @name, @content, @path = type, name, content, path
  end

  attr_reader :type, :name, :content, :path

  def origin
    "#{type}:#{name}"
  end
end
