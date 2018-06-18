# accepts a path to a node-file
# provides affected node names and definition

class Project::File
  def initialize project_file_path
    @path = project_file_path
    @definitions = []
    @capabilities = []
    method_names_cache = methods(false)
    instance_eval File.read project_file_path
    (methods(false) - method_names_cache).each do |capability_name|
      @capabilities.append Capability.new(
        name:    capability_name.to_sym,
        content: method(capability_name).to_proc
      )
    end
  end

  attr_reader :capabilities, :definitions, :path

  private

  def group name=nil
    @definitions.append Definition.new(
      type:    :group,
      name:    name,
      content: Proc.new
    )
  end

  def node names=nil
    [names].flatten(1).each do |name|
      @definitions.append Definition.new(
        type:    name.class == Regexp ? :pattern : :node,
        name:    name,
        content: Proc.new
      )
    end
  end
end
