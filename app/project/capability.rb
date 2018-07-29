# holds a capability in form of an unbound method, extracted from
# Project::Sandbox module
# type - regular: 'cap', final: 'cap!'

class Project::Capability
  def initialize name:, content:, path:
    @name = name
    @content = content
    @type = type
    @path = path
  end

  attr_reader :name, :content, :path

  def type
    @name[-1] == "!" ? :final : :regular
  end

  def to_str
    name.to_s
  end
end
