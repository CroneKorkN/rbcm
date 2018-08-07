# extracts capabilities and definitions from project files

class RBCM::Project::ProjectFile
  def initialize project:, path:
    @project = project
    @path = path
    @definitions = []
    @capabilities = []
    @addons = []
    file = File.read path
    method_names_cache = methods(false)
    instance_eval file
    sandbox = RBCM::Project::Sandbox.dup
    sandbox.module_eval(file)
    sandbox.instance_methods.each do |name|
      raise "ERROR: capability name '#{name}' not allowed" if [:node, :group].include? name
      @capabilities.append RBCM::Project::Capability.new(
        name:         name,
        content:      sandbox.instance_method(name),
        project_file: self
      )
    end
  end

  attr_reader :project, :capabilities, :definitions, :addon_names, :path, :addons

  private

  def addon branch: "master", **named
    raise "illegal project source: #{keys}" if (
      keys = named.keys - [:github, :dir, :file]
    ).any?
    named.each do |type, name|
      @addons.append RBCM::Addon.new type: type, name: name
    end
  end

  def group name=nil
    @definitions.append RBCM::Project::Definition.new(
      type:    :group,
      name:    name,
      content: Proc.new,
      project_file: self
    )
  end

  def node names=nil
    [names].flatten(1).each do |name|
      @definitions.append RBCM::Project::Definition.new(
        type:         name.class == Regexp ? :pattern : :node,
        name:         name,
        content:      Proc.new,
        project_file: self
      )
    end
  end

  def relative_path
    @path.gsub /^#{@project.path}/, ""
  end
end
