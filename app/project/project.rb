class Project
  def initialize path, template_engines: [:mustache, :erb]
    @path = path
    @files = []
    @templates = []
    @else = []
    if File.directory? path
      Dir["#{path}/**/*"].each do |path|
        if path.end_with? ".rb"
          @files << Project::ProjectFile.new(path)
        elsif template_engines.include? path.split(".").last.to_sym
          @templates << path
        else
          @else << path
        end
      end
      p @templates
    else
      @files = [Project::ProjectFile.new(path)]
    end
    raise "ERROR: empty project" unless @files.any?
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

  #TODO?
  def template name
    # @templates.find{|name| name...}
  end
end
