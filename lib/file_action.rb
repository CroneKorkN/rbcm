# ToDo: approve all changes to a spicific file at once

class FileAction < Action
  attr_reader :path

  def initialize node:, path:, params:, trigger: nil, triggered_by: nil, chain:, job:
    @node = node
    @path = path
    @chain = chain
    @capability = :file
    @params = params
    @obsolete = nil
    @approved = nil
    @trigger = [trigger, chain.last].flatten.compact
    @triggered_by = [triggered_by].flatten.compact
    @dependencies = []
    @job = job
  end

  def check
    log "CHECKING $>_ #{@check}"
    # get file content
    @node.files[path] = if @params[:content]
      @params[:content]
    elsif @params[:template]
      Template.new(
        name: @params[:template],
        capability: @chain[-2],
        context: @params[:context]
      ).render
    end
    @obsolete = @node.remote.files[path].chomp.chomp == @node.files[path].chomp.chomp
  end

  def diff
    path = @params.first
    return @diff ||= Diffy::Diff.new(
      @node.remote.files[path],
      @node.files[path]
    ).to_s(:color)
  end

  def siblings
    [] # tbd
  end

  def apply
    super @node.remote.execute("echo #{Shellwords.escape(@node.files[path])} > #{path}")
  end
end
