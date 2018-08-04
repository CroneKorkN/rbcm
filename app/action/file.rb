# ToDo: approve all changes to a spicific file at once
class Action::File < Action
  attr_reader :path, :content

  def check!
    # compare
    @job.node.files[path].content
  end

  def obsolete
    @job.node.files[path].content.chomp.chomp == content.chomp.chomp
  end

  def siblings
    [] # TODO
  end

  def apply!
    @applied = true
    @result = @job.node.remote.execute("echo #{Shellwords.escape content} > #{path}")
  end

  def content
    @content ||= if @params[:content]
      @params[:content].to_s
    elsif @params[:template]
      # @node.rbcm.project.templates.find_for(
      #  @params[:template]
      # ).render context: @params[:context]
      Node::Template.new(
        name: @params[:template],
        capability: @chain[-1],
      ).render context: @params[:context]
    end
  end

  def same_file
    @job.node.actions.file(path) - [self]
  end
end
