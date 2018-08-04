class Project
  def initialize path, template_engines: [:mustache, :erb], addon: false
    @path = path
    @files = []
    @templates = []
    @other = []
    @directories = []
    @template_engines = template_engines
    load_files path
  end

  attr_reader :path, :files, :templates, :other, :directories

  def capabilities
    files.each.capabilities.flatten(1).compact
  end

  def definitions type=nil
    with files.each.definitions.flatten(1) do
      return select{|definition| definition.type == type} if type
      return self
    end
  end

  def files
    (@files + all_addons.each.project.each.files).flatten
  end

  def addons
    @files.each.addons.flatten
  end

  # collect addons recursively
  def all_addons project=self
    cache = project.addons
    if project.addons.any?
      cache += project.addons.each.project.collect{|project| all_addons project}
    end
    cache.flatten
  end

  #TODO?
  def template name
    # @templates.find{|name| name...}
  end

  private

  def load_files path
    if File.directory? path
      Dir["#{path}/**/*"].each do |file_path|
        if file_path.end_with? ".rb"
          @files << Project::ProjectFile.new(self, file_path)
        elsif @template_engines.include? file_path.split(".").last.to_sym
          @templates << file_path.sub(@path, "")
        elsif File.directory? path
          @directories << file_path.sub(@path, "")
        else
          @other << file_path.sub(@path, "")
        end
      end
      log "templates: #{@templates}"
    else
      @files = [Project::ProjectFile.new(@path)]
    end
    raise "ERROR: empty project" unless @files.any?
  end
end
