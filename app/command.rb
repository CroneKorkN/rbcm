class Command
  attr_accessor :line
  attr_accessor :capability
  attr_accessor :dependencies

  def initialize line, capability, dependencies
    @capability = capability
    @line = line
    @dependencies = [:file] + dependencies
  end
end

class CommandList < Array
  def render
    solve_dependencies!
    self.collect {|command| command.line}.join("\n")
  end

  def solve_dependencies!
    
  end
end
