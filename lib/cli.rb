class CLI
  def initialize core, params
    # parse
    options = Options.new params
    puts "\n================ RBCM starting ================\n\n"
    core.parse

    # check
    puts "\n================ CHECKING #{core.nodes.count} nodes ================\n\n"
    core.actions.each.check

    # approve
    puts "\n================ APPROVING #{core.actions.select{|a| a.obsolete == false}.count} actions ================\n\n"
    core.actions.resolve_triggers.each.approve

    # apply
    puts "\n================ APPLYING #{core.actions.approved.count} actions ================\n\n"
    core.actions.approved.resolve_dependencies.each.apply
  end

  def check action

  end

  def approve action

  end
end
