class CommandCollector < Capabilities
  attr_reader :commands

  def initialize node
    # cap
    @node = node
    @commands = []
    @dependency_cache = []
    node.definitions.each do |definition|
      instance_eval &definition.content
    end
    # cap!
    @getter_methods = true
    @node.capabilities.each do |capability|
      @node.send capability + '!'
    end
  end
end
