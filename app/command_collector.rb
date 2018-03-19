class CommandCollector < Capabilities
  attr_reader :commands

  def initialize node
    @node = node
    @commands = []
    @dependency_cache = []
    node.definitions.each do |definition|
      instance_eval &definition.definition
    end
  end
end
