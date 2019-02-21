class RBCM::Project
  def initialize path, template_engines: [:mustache, :erb, :encrypted, :template], addon: false
    @path = path
    @templates = RBCM::TemplateList.new
    @other = []
    @directories = []
    @template_engines = template_engines
    @jobs = RBCM::JobList.new
    @definitions = RBCM::DefinitionList.new
    load_files
  end

  attr_reader :path, :templates, :directories, :templates, :jobs, :definitions
  
  private
  
  def load_files
    if File.directory? @path
      Dir["#{@path}/**/*"].each do |file_path|
        if file_path.end_with? ".rb"
          load_file file_path
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
      load_file @path
    end
    raise "ERROR: empty project" unless @definitions.any?
  end
  
  def load_file path
    @definitions.append RBCM::Definition.new(
      type:    :file,
      name:    path,
      content: ->{load path}
    )
    @jobs.append RBCM::Job.new(
      type: :file, 
      name: path
    )
  end
end
