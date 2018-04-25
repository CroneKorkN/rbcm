class Remote
  def initialize node
    @node = node
    @files = FileSystem.new @node
  end

  attr_reader :files

  def execute command
    Execution.new @node.name, command: command
  end
end
