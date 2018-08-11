class RBCM::Project
  def initialize path, template_engines: [:mustache, :erb], addon: false
    @path = path
    @files = []
    @templates = RBCM::Project::TemplateList.new
    @other = []
    @directories = []
    @template_engines = template_engines
    load_files path
  end

  attr_reader :path, :files, :templates, :other, :directories, :templates

  def capabilities
    files.each.capabilities.flatten.compact
  end

  def definitions type=nil
    with files.each.definitions.flatten do
      return select{|definition| definition.type == type} if type
      return self
    end
  end

  def files
    (@files + all_addons.each.files).flatten
  end

  def addons
    @files.each.addons.flatten
  end

  # collect addons recursively
  def all_addons project=self
    ( project.addons + project.addons.collect{|project| all_addons project}
    ).flatten
  end

  private

  def load_files path
    if File.directory? path
      Dir["#{path}/**/*"].each do |file_path|
        if file_path.end_with? ".rb"
          @files.append RBCM::Project::ProjectFile.new(
            project: self,
            path:    file_path
          )
        elsif @template_engines.include? file_path.split(".").last.to_sym
          @templates.append RBCM::Project::Template.new(
            project: self,
            path:    file_path
          )
        elsif File.directory? path
          @directories << file_path.sub(@path, "")
        else
          @other << file_path.sub(@path, "")
        end
      end
    else
      @files = [
        RBCM::Project::ProjectFile.new(
          project: self,
          path:    path
        )
      ]
    end
    raise "ERROR: empty project" unless @files.any?
  end
end
