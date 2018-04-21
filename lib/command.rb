class Command
  include Params
  attr_reader :line, :capability, :params, :dependencies, :approved

  def initialize line:, capability:, params:, dependencies:
    @line = line
    @capability = capability
    @params = params
    @dependencies = [:file] + [dependencies].flatten - [capability]
  end

  def approve
    
  end

  def to_s
    "> #{@line.ljust(40, " ")} # #{@capability.to_s.ljust(10, " ")} # #{@dependencies}"
  end

  def to_s
    "#{@capability} #{@params.to_s[1..-2]}\n  #{@line}"
  end
end
