# accepts a path to a node-file

class Project::File
  def initialize project_file_path
    @path = project_file_path
    @definitions = []
    @capabilities = []
    file = File.read project_file_path
    method_names_cache = methods(false)
    instance_eval file
    capability_module = Project::File::Capabilities.dup
    capability_module.module_eval(file)
    capability_module.instance_methods.each do |capability_name|
      @capabilities.append Capability.new(
        name:    capability_name.to_sym,
        content: capability_module.instance_method(capability_name).bind(Sandbox)
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
