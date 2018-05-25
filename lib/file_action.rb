# ToDo: approve all changes to a spicific file at once
class FileAction < Action
  attr_reader :path, :content

  def check!
    # compare
    @obsolete = @node.remote.files[path].chomp.chomp == content.chomp.chomp
  end

  def siblings
    [] # tbd
  end

  def apply!
    @result = @node.remote.execute("echo #{Shellwords.escape content} > #{path}")
  end

  def content
    @content ||= if @params[:content]
      @params[:content]
    elsif @params[:template]
      Template.new(
        name: @params[:template],
        capability: @chain[-2],
        context: @params[:context]
      ).render
    end
  end
end
