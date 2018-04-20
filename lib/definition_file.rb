# accepts a path to a node-file
# provides affected node names and definition

class DefinitionFile
  attr_reader :groups, :patterns, :nodes

  def initialize definition_file
    @groups = {}
    @patterns = {}
    @nodes = {}
    instance_eval File.read definition_file
  end

  def group name=nil
    @groups[name] = Definition.new(Proc.new)
  end

  def node names=nil
    return @nodes unless names
    [names].flatten.each do |name|
      definition = Definition.new(Proc.new) # Proc.new without paramaters catches a given block
      if name.class == Regexp
        @patterns[name] = definition
      else
        @nodes[name] = definition
      end
    end
  end
end
