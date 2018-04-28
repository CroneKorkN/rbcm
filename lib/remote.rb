class Remote
  attr_reader :files

  def initialize node
    @files = FileSystem.new node
    @session = Net::SSH.start node.name, 'root'
  end

  def execute command
    @session.exec! command
  end
end

# @session = Net::SSH.start 'test.ckn.li', 'root'
# @session.exec!("ls").class
