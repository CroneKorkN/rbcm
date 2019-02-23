class RBCM::Check
  def initialize node, command
    @node, @command = node, command
  end
  
  attr_reader :node, :command
  
  def result
    @node.remote.execute(@command).exitstatus
  end
end
