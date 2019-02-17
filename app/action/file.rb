# ToDo: approve all changes to a spicific file at once
class RBCM::Action::File < RBCM::Action
  attr_reader :path, :content

  def check!
    @job.node.files[path].content
  end

  def obsolete
    return true if @params[:provide_once] and @job.node.files[path].content.to_s.length > 0
    return @job.node.files[path].content == content
  end

  def siblings
    [] # TODO
  end

  def apply!
    @applied = true
    #@result = @job.node.remote.execute("echo #{Shellwords.escape content} > #{path}")
    @result = Net::SCP::upload!(@job.node.name, nil, StringIO.new(content), @params[0])
    def @result.exitstatus
      self.class == TrueClass ? 0 : 1
    end
    @result
  end

  def content
    @content ||= if @params[:content]
      @params[:content].to_s
    elsif @params[:includes]
      old = @job.node.files[path].content
      (old.include? @params[:includes]) ? old : [old, @params[:includes]].join("\n")
    elsif @params[:template]
      project_file.project.templates.for(self).render(
        context: @params[:context]
      )
    elsif @params[:provide] or @params[:provide_once]
      provide = (@params[:provide] or @params[:provide_once]).to_sym
      provider = @job.node.rbcm.providers.select{ |provider|       # filter providers
        provider[:name].to_sym == provide
      }.select{ |provider|                              # filter neighbors
        provider[:node].name == @job.node.name or       # same node
        @job.node.memberships.include? provider[:group] # same group
      }.first
      raise "no provider found for '#{provide}' on '#{@job.node}'" unless provider
      provider[:node].remote.execute (provider[:command] % @params[:context].to_h)
    end
  end

  def same_file
    @job.node.actions.file(path) - [self]
  end
end
