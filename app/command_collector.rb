class CommandCollector < Capabilities
  attr_accessor :commands

  def initialize node
    node.definitions.each do |definition|
      instance_eval definition
    end
  end
end
