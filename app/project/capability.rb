# holds a capability in form of an unbound method, extracted from
# Project::Sandbox module
# type - regular: 'cap', final: 'cap!'

class Project::Capability
  def initialize name:, content:, project_file:
    @name = name
    @content = content
    @type = type
    @project_file = project_file
  end

  attr_reader :name, :content, :project_file

  def type
    @name[-1] == "!" ? :final : :regular
  end

  def to_str
    name.to_s
  end
end
