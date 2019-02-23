class RBCM::Action::Command < RBCM::Action
  def run
    @node.remote.execute @params[0]
  end
  
  # execute the command remote
  def run!
    @applied = true
    @result = @node.remote.execute(@params[:line])
  end
end
