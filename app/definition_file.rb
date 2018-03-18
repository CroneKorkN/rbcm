# accepts a path to a node-file
# provides each: a hash with affected nodes and with patterns

class DefinitionFile
  attr_reader :nodes, :patterns

  def initialize definition_file
    @node = {}
    @patterns = {}
    instance_eval File.read definition_file
  end

  private

  def nodes names=nil
    names.each do |name|
      if name.class == Regexp
        @patterns[name] = @definition
      else
        @nodes[name] = @definition
      end
    end
  end
end
