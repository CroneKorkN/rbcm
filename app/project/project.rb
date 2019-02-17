class RBCM::Project
  def initialize path, template_engines: [:mustache, :erb, :encrypted, :template], addon: false
    @path = path
    @files = []
    @templates = RBCM::TemplateList.new
    @other = []
    @directories = []
    @template_engines = template_engines
    load_files
  end

  attr_reader :path, :templates, :directories, :templates, :nodes
  
  def definitions
    @files.each.definitions.flatten
  end

  # collect addons recursively
  def addons
    direct_addons = @files.each.addons.flatten
    [ direct_addons,
      *direct_addons.collect{|project| project.addons}
    ]
  end
  
  private
  
  def load_files
    if File.directory? @path
      Dir["#{@path}/**/*"].each do |file_path|
        if file_path.end_with? ".rb"
          @files.append RBCM::ProjectFile.new(
            project: self,
            path:    file_path
          )
        elsif @template_engines.include? file_path.split(".").last.to_sym
          @templates.append RBCM::Template.new(
            project: self,
            path:    file_path
          )
        elsif File.directory? @path
          @directories << file_path.sub(@path, "")
        else
          @other << file_path.sub(@path, "")
        end
      end
    else
      @files = [
        RBCM::ProjectFile.new(
          project: self,
          path:    @path
        )
      ]
    end
    raise "ERROR: empty project" unless @files.any?
  end
end
