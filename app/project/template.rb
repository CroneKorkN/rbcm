class RBCM::Project::Template
  @@engines = [:erb, :mustache]

  def initialize project:, path:
    @project = project
    @path    = path
    @content = File.read path
  end

  attr_accessor :project, :path

  def render context: {}
    cache = @content
    engine_names.each do |layer|
      if layer == :mustache
        require "mustache"
        cache = Mustache.render(@content, **context)
      elsif layer == :erb
        # https://zaiste.net/rendering_erb_template_with_bindings_from_hash/
        require "ostruct"; require "erb"
        cache = ERB.new(@content).result(
          OpenStruct.new(context).instance_eval{binding}
        )
      end
    end
    return cache
  end

  def clean_full_path
    path.gsub(
      /#{engine_names.reverse.collect{|e| ".#{e}"}.join}$/, ''
    )
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
      layer.to_sym if @@engines.include? layer.to_sym
    }.compact
  end
end
