# ToDo: approve all changes to a spicific file at once

class FileAction < Action
  attr_reader :path

  def initialize node:, path:, params:, trigger: nil, triggered_by: nil, chain:
    @node = node
    @path = path
    @chain = chain
    @capability = :file
    @params = params
    @obsolete = nil
    @approved = nil
    @trigger = [trigger, chain.last].flatten.compact
    p @trigger
    @triggered_by = [triggered_by].flatten.compact
    @dependencies = []
  end

  def check
    log "CHECKING $>_ #{@check}"
    # get file content
    @node.files[path] = if params[:content]
      params[:content]
    elsif params[:template]
      Template.new(
        @node.rbcm.project_path, @chain[-2], params[:template], context: @params[:context]
      ).render
    end
    @obsolete = @node.remote.files[path].chomp == @node.files[path].chomp
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
