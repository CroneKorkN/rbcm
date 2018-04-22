class Command
  include Params
  attr_reader :line, :capability, :params, :dependencies, :approved

  def initialize line:, capability:, params:, dependencies:, check: nil
    @line = line
    @check = check
    @capability = capability
    @params = params
    @dependencies = [:file] + [dependencies].flatten - [capability]
    @approved = nil
  end

  def check node
    @node = node
    @check ||= @node.remote.execute!(@check).success?
    p @check
    @check
  end

  def approve node
    p "#{self} unneccessary" and return if check
    if read == "y"
      @approved = true
    else
      @approved = false
    end
  end

  def to_s
    "#{@capability} #{@params.to_s[1..-2]}\n  #{@line}"
  end
end
