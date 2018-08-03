# extracts capabilities and definitions from project files

class Project::ProjectFile
  def initialize project, project_file_path
    @project = project
    @path = project_file_path
    @definitions = []
    @capabilities = []
    @include = {github: [], dir: [], file: []}
    file = File.read project_file_path
    method_names_cache = methods(false)
    instance_eval file
    sandbox = Project::Sandbox.dup
    sandbox.module_eval(file)
    sandbox.instance_methods.each do |name|
      raise "ERROR: capability name '#{name}' not allowed" if [:node, :group].include? name
      @capabilities.append Project::Capability.new(
        name:    name,
        content: sandbox.instance_method(name),
        path:    relative_path
      )
    end
  end

  attr_reader :capabilities, :definitions, :path

  private

  def include_project **named
    if (keys = named.keys - [:github, :dir, :file]).any?
      raise "illegal project source: #{keys}"
    end
    named.each do |type, name|
      @include[type] << name
    end
  end

  def group name=nil
    @definitions.append Project::Definition.new(
      type:    :group,
      name:    name,
      content: Proc.new,
      path:    relative_path
    )
  end

  def node names=nil
    [names].flatten(1).each do |name|
      @definitions.append Project::Definition.new(
        type:    name.class == Regexp ? :pattern : :node,
        name:    name,
        content: Proc.new,
        path:    relative_path
      )
    end
  end

  def relative_path
    @path.gsub /^#{@project.path}/, ""
  end
end
