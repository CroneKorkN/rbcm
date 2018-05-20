class Template
  @@engines = [:erb, :mustache]

  def initialize name:, capability:, context: {}
    @name = name
    @capability = capability
    @context = context
  end

  def render
    content = File.read path
    layers.each do |layer|
      if layer == :mustache
        require "mustache"
        content = Mustache.render(content, **@context)
      elsif layer == :erb
        # https://zaiste.net/rendering_erb_template_with_bindings_from_hash/
        require "ostruct"; require "erb"
        content = ERB.new(content).result(
          OpenStruct.new(@context).instance_eval{binding}
        )
      end
    end
    return content
  end

  private

  def path
    @path ||= Dir["#{@@project_path}/capabilities/#{@capability.to_s.gsub("!","")}/#{@name}*"].first
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

  def self.project_path= path
    @@project_path = path
  end
end
