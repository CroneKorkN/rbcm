class Command
  attr_accessor :line
  attr_accessor :capability
  attr_accessor :dependencies

  def initialize line, capability, dependencies
    @capability = capability
    @line = line
    @dependencies = [:file] + [dependencies].flatten
    @ordered = []
  end
end
