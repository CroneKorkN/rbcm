# accepts a path to a node-file
# provides affected node names and definition

class Project::File
  def initialize project_file_path
    @path = project_file_path
    @groups = {}
    @patterns = {}
    @nodes = {}
    @capabilities = {}
    methods_cache = methods(false)
    instance_eval File.read project_file_path
    capability_names = methods(false) - methods_cache
    capability_names.each do |capability_name|
      @capabilities[capability_name] = method capability_name
    end
  end

  attr_reader :capabilities, :groups, :patterns, :nodes, :path

  private

  def group name=nil
    @groups[name] = Definition.new Proc.new
  end

  def node names=nil
    return @nodes unless names
    [names].flatten.each do |name|
      definition = Proc.new # Proc.new without paramaters catches a given block
      if name.class == Regexp
        @patterns[name] = Definition.new Proc.new, origin: "/#{name.source}/"
      else
        @nodes[name] = Definition.new Proc.new
      end
    end
  end
end
