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
    @trigger = trigger + [chain.last]
    @triggered_by = triggered_by
    @dependencies = []
  end

  def check
    log "CHECKING $>_ #{@check}"
    if params[:template]
      content = Template.new(
        @node.rbcm.project_path, params[:template]
      ).render
    else
      content = params[:content]
    end
    @node.files[path] = content
    @obsolete = @node.remote.files[path].chomp == @node.files[path].chomp
  end

  def diff
    path = @params.first
    return @diff ||= Diffy::Diff.new(
      @node.remote.files[path],
      @node.files[path]
    ).to_s(:color)
  end
end
