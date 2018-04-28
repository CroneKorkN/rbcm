class Remote
  def initialize node
    @node = node
    @files = FileSystem.new @node
    @session = Net::SSH.start @node.name, 'root'
  end

  attr_reader :files

  def execute command
    @session.exec! @command
  end
end
