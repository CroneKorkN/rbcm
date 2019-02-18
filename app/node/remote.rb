class RBCM::Node::Remote
  def initialize node
    @node = node
    @files = RBCM::Node::NodeFilesystem.new node
  end

  attr_reader :node, :files

  def execute action
    p "========================== REMOTE"
    @session ||= Net::SSH.start @node.name
    @session.exec! action
  end
end
