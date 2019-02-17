def file *params
  @env.node.actions.append RBCM::Action::File.new(@job, *params)
end
