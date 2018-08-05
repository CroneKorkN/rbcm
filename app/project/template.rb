class Project::Template
  @@engines = [:erb, :mustache]

  def initialize project:, path:
    @project = project
    @path    = path
  end

  attr_accessor :path

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

  def filename
    File.basename(path)
  end

  def target_filename
    filename.gsub /#{engine_names.reverse.join('.')}$/, ''
  end

  def path_in_project

  end

  def engine_names
    filename.split(".").reverse.each.to_sym.collect do |layer|
      break unless @@engines.include? layer
      layer
    end
  end
end
