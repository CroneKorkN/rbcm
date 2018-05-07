class Template
  @@engines = [:mustache]

  def initialize project_path, capability, template_name, context: {}
    @project_path = project_path
    @capability = capability
    @template_name = template_name
    @context = context
  end

  def render
    content = File.read path
    p content
    p layers
    layers.each do |layer|
      if layer == :mustache
        content = Mustache.render(content, **@context)
      else
        raise "RBCM: unknown template engine '#{layer}'"
      end
    end
    return content
  end

  def path
    @path ||= Dir["#{@project_path}/capabilities/#{@capability.to_s.gsub("!","")}/#{@template_name}*"].first
  end

  def filename
    File.basename(path)
  end

  def layers
    @layers = []
    filename.split(".").reverse.each.to_sym.each do |layer|
      if @@engines.include? layer
        @layers << layer
      else
        break
      end
    end
    return @layers
  end
end
