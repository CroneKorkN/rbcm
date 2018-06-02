# accepts a path to a node-file
# provides affected node names and definition

class DefinitionFile
  attr_reader :groups, :patterns, :nodes, :path

  def initialize definition_file_path
    @path = definition_file_path
    @groups = {}
    @patterns = {}
    @nodes = {}
    instance_eval File.read definition_file_path
  end

  def group name=nil
    @groups[name] = Proc.new
  end

  def node names=nil
    return @nodes unless names
    [names].flatten.each do |name|
      definition = Proc.new # Proc.new without paramaters catches a given block
      if name.class == Regexp
        @patterns[name] = definition
      else
        @nodes[name] = definition
      end
    end
  end
end
