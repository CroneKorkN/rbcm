# accepts a path to a node-file

class Project::File
  def initialize project_file_path
    @path = project_file_path
    @definitions = []
    @capabilities = []
    file = File.read project_file_path
    method_names_cache = methods(false)
    instance_eval file
    sandbox = Project::Sandbox.dup
    sandbox.module_eval(file)
    sandbox.instance_methods.each do |name|
      @capabilities.append Project::Capability.new(
        name:    name,
        content: sandbox.instance_method(name)
      )
    end
  end

  attr_reader :capabilities, :definitions, :path

  private

  def group name=nil
    @definitions.append Project::Definition.new(
      type:    :group,
      name:    name,
      content: Proc.new
    )
  end

  def node names=nil
    [names].flatten(1).each do |name|
      @definitions.append Project::Definition.new(
        type:    name.class == Regexp ? :pattern : :node,
        name:    name,
        content: Proc.new
      )
    end
  end
end
