class RBCM
  def initialize
    @nodes = {}
  end

  def run command
    log `sudo #{command}`
  end

  def log entry
    puts entry
  end

  def node name
    @nodes[name] = Node.new name unless @nodes[node_name]
    @nodes[name].add_recipes Proc.new # catches the given block
  end

  def apply
    @nodes.each do |node|
      node.apply
    end
  end
end
# run every file in ../config/nodesö

# recipe: returns bash to be executed on node
