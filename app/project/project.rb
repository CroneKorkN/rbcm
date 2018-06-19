class Project
  def initialize path
    @path = path
    @files = Dir["#{path}/**/*.rb"].collect{ |project_file_path|
      Project::File.new project_file_path
    }
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
