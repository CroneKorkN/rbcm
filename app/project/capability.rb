# holds a capability in form of an unbound method, extracted from
# Project::Sandbox module

class Project::Capability
  def initialize name:, content:
    @name = name
    @content = content
    @type = type
  end

  attr_reader :name, :content

  def type
    @name[-1] == "!" ? :final : :regular
  end
end
