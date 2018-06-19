class Project
  def initialize path
    @path = path
    if File.directory? path
      @files = Dir["#{path}/**/*.rb"].collect{ |project_file_path|
        Project::ProjectFile.new project_file_path
      }
    elsif
      @files = [Project::ProjectFile.new(path)]
    end
  end

  attr_reader :path, :files

  def capabilities
    @files.each.capabilities.flatten(1).compact
  end

  def definitions type=nil
    with @files.each.definitions.flatten(1) do
      return select{|definition| definition.type == type} if type
      return self
    end
  end
end
