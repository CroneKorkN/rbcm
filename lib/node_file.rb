# accepts a path to a node-file
# provides affected node names and definition

class NodeFile
  attr_reader :affected_nodes, :definition

  def initialize definition_file
    @affected_nodes = []
    @definition = Proc
    instance_eval File.read definition_file
  end

  private

  def nodes names=nil
    @affected_nodes += [names].flatten
    @definition = Definition.new(Proc.new) # Proc.new without paramaters catches a given block
  end
end
