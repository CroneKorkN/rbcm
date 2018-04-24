class Remote
  def initialize node
    @node = node
    @files = FileList.new self
  end

  def execute command
    Execution.new @node.name, command: command
  end
end
