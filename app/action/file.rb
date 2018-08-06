# ToDo: approve all changes to a spicific file at once
class Action::File < Action
  attr_reader :path, :content

  def check!
    # compare
    @job.node.files[path].content
  end

  def obsolete
    @job.node.files[path].content == content
  end

  def siblings
    [] # TODO
  end

  def apply!
    @applied = true
    #@result = @job.node.remote.execute("echo #{Shellwords.escape content} > #{path}")
    @result = Net::SCP::upload!(@job.node.name, "root", StringIO.new(content), @params[0])
    def @result.exitstatus
      self.class == TrueClass ? 0 : 1
    end
    @result
  end

  def content
    @content ||= if @params[:content]
      @params[:content].to_s
    elsif @params[:template]
      project_file.project.templates.for(self).render(
        context: @params[:context]
      )
    end
  end

  def same_file
    @job.node.actions.file(path) - [self]
  end
end
