# accepts a path to a node-file
# provides affected node names and definition

class NodeFile
  attr_reader :affected_nodes, :affected_groups, :definition

  def initialize definition_file
    @affected_nodes = []
    @affected_groups = []
    @definition = Proc
    instance_eval File.read definition_file
  end

  private

  def nodes names=nil
    @affected_nodes += [names].flatten
    @definition = Definition.new(Proc.new) # Proc.new without paramaters catches a given block
  end

  def group name
    @affected_groups += [names].flatten
    @definition = Definition.new(Proc.new) # Proc.new without paramaters catches a given block
  end
end
