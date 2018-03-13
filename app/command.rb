class Command
  attr_accessor :line
  attr_accessor :capability
  attr_accessor :dependencies

  def initialize line, capability, dependencies
    @capability = capability
    @line = line
    @dependencies = [:file] + dependencies
    @ordered = []
  end
end

class CommandList < Array
  def render
    solve_dependencies.collect {|command| command.line}.join("\n")
  end

  # return with solved dependencies
  def solve_dependencies
    self
  end
end
