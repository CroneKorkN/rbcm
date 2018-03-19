class Command
  attr_accessor :line
  attr_accessor :capability
  attr_accessor :dependencies

  def initialize line, capability, dependencies
    @capability = capability
    @line = line
    @dependencies = [:file] + [dependencies].flatten - [capability]
  end

  def to_s
    "> #{@line.ljust(40, " ")} # #{@capability.to_s.ljust(10, " ")} # #{@dependencies}"
  end
end
