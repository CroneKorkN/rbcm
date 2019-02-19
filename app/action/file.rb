# ToDo: approve all changes to a spicific file at once
class RBCM::Action::File < RBCM::Action
  def run
    
  end
  
  def check
    @node.files[path].content
  end
  
  def run!
    @applied = true
    @result = Net::SCP::upload!(@node.name, nil, StringIO.new(content), @params[0])
    def @result.exitstatus
      self.class == TrueClass ? 0 : 1
    end
    @result
  end
  
  def content
    @content ||= if @params[:content]
      @params[:content].to_s
    elsif @params[:includes]
      old = @node.files[path].content
      (old.include? @params[:includes]) ? old : [old, @params[:includes]].join("\n")
    elsif @params[:template]
      project_file.project.templates.for(self).render(
        context: @params[:context]
      )
    elsif @params[:provide] or @params[:provide_once]
      provide = (@params[:provide] or @params[:provide_once]).to_sym
      provider = @node.rbcm.providers.select{ |provider|       # filter providers
        provider[:name].to_sym == provide
      }.select{ |provider|                              # filter neighbors
        provider[:node].name == @node.name or       # same node
        @node.memberships.include? provider[:group] # same group
      }.first
      raise "no provider found for '#{provide}' on '#{@node}'" unless provider
      provider[:node].remote.execute \
        (provider[:command] % @params[:context].to_h)
    end
  end
end
