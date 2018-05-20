# ToDo: approve all changes to a spicific file at once
class FileAction < Action
  attr_reader :path

  def check!
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

  def siblings
    [] # tbd
  end

  def apply!
    @node.remote.execute("echo #{Shellwords.escape(@node.files[path])} > #{path}")
  end
end
