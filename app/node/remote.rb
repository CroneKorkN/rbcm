class Node::Remote
  def initialize node
    @node = node
    @files = Node::NodeFilesystem.new node
  end

  attr_reader :node, :files

  def execute action
    @session ||= Net::SSH.start @node.name
    @session.exec! action
  end
end

# @session = Net::SSH.start 'test.ckn.li'
# @session.exec!("ls").class
