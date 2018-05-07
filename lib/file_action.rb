# ToDo: approve all changes to a spicific file at once
class FileAction < Action
  attr_reader :path

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
    # compare
    @obsolete = @node.remote.files[path].chomp.chomp == @node.files[path].chomp.chomp
  end

  def diff
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
