class Project::Template
  @@engines = [:erb, :mustache]

  def initialize project:, path:
    @project = project
    @path    = path
  end

  attr_accessor :project, :path

  def render context: {}
    content = File.read path
    engine_names.each do |layer|
      if layer == :mustache
        require "mustache"
        content = Mustache.render(content, **context)
      elsif layer == :erb
        # https://zaiste.net/rendering_erb_template_with_bindings_from_hash/
        require "ostruct"; require "erb"
        content = ERB.new(content).result(
          OpenStruct.new(context).instance_eval{binding}
        )
      end
    end
    return content
  end

  def clean_path
    path.gsub(/^#{project.path}/, '').gsub(
      /#{engine_names.reverse.collect{|e| ".#{e}"}.join}$/, ''
    )
  end

  def clean_filename
    File.basename(clean_path)
  end

  def engine_names
    path.split(".").reverse.collect{ |layer|
      layer if @@engines.include? layer.to_sym
    }.compact
  end
end
