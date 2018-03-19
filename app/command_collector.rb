class CommandCollector < Capabilities
  attr_accessor :commands

  def initialize node
    @node = node
    @commands = []
    @dependency_cache = []
    node.definitions.each do |definition|
      instance_eval &definition.definition
    end
  end

  def ckn
    :ckn
  end
end
