# extracts capabilities and definitions from project files

class RBCM::ProjectFile
  def initialize project:, path:
    @project = project
    @path = path
    @addons = []
    @definitions = RBCM::DefinitionList.new
    file = File.read path
    method_names_cache = methods(false)
    instance_eval file
    sandbox = RBCM::Project::Sandbox.dup
    sandbox.module_eval(file)
    sandbox.instance_methods.each do |name|
      raise "ERROR: capability name '#{name}' not allowed" if [:node, :group].include? name
      @definitions.append RBCM::Project::Definition.new(
        type:         :capability,
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

  def group name=nil, *named, **ordered
    @definitions.append RBCM::Definition.new(
      type:    :group,
      name:    name,
      content: Proc.new,
      project_file: self
    )
  end

  def node names=nil, *named, **ordered
    [names].flatten(1).each do |name|
      @definitions.append RBCM::Definition.new(
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
