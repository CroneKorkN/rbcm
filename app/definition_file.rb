# accepts a path to a node-file
# provides affected node name (Array) and definition (Proc)

class DefinitionFile
  attr_reader :affected_nodes, :definition

  def initialize definition_file
    instance_eval File.read definition_file
  end

  private

  def nodes names=nil
    @affected_nodes = [names].flatten
    @definition = Proc.new # Proc.new without paramaters catches a given block
  end
end
