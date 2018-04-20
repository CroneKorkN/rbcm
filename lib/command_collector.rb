class CommandCollector < Capabilities
  attr_reader :commands

  def initialize node
    @node = node
    @commands = []
    @dependency_cache = []
    node.definitions.each do |definition|
      instance_eval &definition.definition
    end
    node.capabilities.each do |capability|
      begin
        send "#{capability}!"
      rescue NoMethodError
      end
    end
  end

  def group name
    #instance_eval &@node.groups[name]
  end
end
