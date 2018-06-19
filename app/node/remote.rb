class Node::Remote
  attr_reader :files

  def initialize node
    @host = node.name
    @files = Node::NodeFilesystem.new node
  end

  def execute action
    @session ||= Net::SSH.start @host, 'root'
    @session.exec! action
  end
end

# @session = Net::SSH.start 'test.ckn.li', 'root'
# @session.exec!("ls").class
