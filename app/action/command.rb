class RBCM::Action::Command < RBCM::Action
  # execute the command remote
  def run!
    @applied = true
    @result = @node.remote.execute(@params.first)
  end
end
