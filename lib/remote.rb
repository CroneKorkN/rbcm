class Remote
  attr_reader :files

  def initialize node
    @host = node.name
    @files = FileSystem.new node
  end

  def execute command
    @session ||= Net::SSH.start @host, 'root'
    @session.exec! command
  end
end

# @session = Net::SSH.start 'test.ckn.li', 'root'
# @session.exec!("ls").class
