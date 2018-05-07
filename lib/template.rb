class Template
  @@engines = [:mustache]

  def initialize project_path, template_name, context: {}
    @context = context
    Dir["#{project_path}/capabilities/**/*"].each do |path|
      @content = File.read(path) if File.basename(path).gsub(".mustache", "") == template_name
    end
    raise "no file found for template '#{template_name}'" unless @content
  end

  def render
    Mustache.render(@content, **@context)
  end
end
