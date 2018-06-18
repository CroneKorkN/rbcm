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

  def definitions type=nil
    with @project_files.each.definitions.flatten(1) do
      return select{|definition| definition.type == type} if type
      return self
    end
  end
end
