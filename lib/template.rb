class Template
  @@engines = [:erb, :mustache]

  def initialize project_path, capability, template_name, context: {}
    @project_path = project_path
    @capability = capability
    @template_name = template_name
    @context = context
  end

  def render
    content = File.read path
    layers.each do |layer|
      if layer == :mustache
        content = Mustache.render(content, **@context)
      elsif layer == :erb
        # https://zaiste.net/rendering_erb_template_with_bindings_from_hash/
        content = ERB.new(content).result(OpenStruct.new(@context).instance_eval{binding})
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
