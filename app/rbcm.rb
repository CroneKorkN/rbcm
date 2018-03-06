class RBCM
  def initialize
    @nodes = {}
  end

  def node node_name
    @nodes[name] = Node.new name unless @nodes[node_name]
    # Proc.new without paramaters catches the given block
    @nodes[name].add_job Proc.new
  end

  def apply
    @nodes.each do |node|
      node.apply
    end
  end
end

def log entry
  puts entry
end

RBCM.new.apply
