# accepts a path to a node-file
# provides affected node names and jobs lists

class NodeFile
  attr_reader :affected_nodes, :jobs

  def initialize definition_file
    @affected_nodes = []
    @jobs = []
    eval File.read definition_file
  end

  private

  def nodes names=nil
    @affected_nodes += [names].flatten
    @jobs << Definition.new(Proc.new).jobs # Proc.new without paramaters catches a given block
  end
end
