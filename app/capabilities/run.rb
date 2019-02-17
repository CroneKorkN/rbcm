def run *params
  @env.node.actions.append RBCM::Action::Command.new(@job, *params)
end
