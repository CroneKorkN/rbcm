class Project
  def initialize path
    @path = path
    @project_files = Dir["#{path}/**/*.rb"].collect{ |project_file_path|
      Project::File.new project_file_path
    }
  end

  attr_reader :path

  def capabilities
    @project_files.each.capabilities.flatten(1)
  end

  def nodes
    @project_files.each.nodes
  end

  def groups
    @project_files.each.pattterns
  end

  def pattterns
    @project_files.each.pattterns
  end
end
