class CLI
  def initialize core, params
    options = Options.new params

    # parse
    puts title "RBCM starting"
    core.parse

    # check
    puts title "CHECKING #{core.nodes.count} nodes"
    core.actions.each.check

    # approve
    puts title "APPROVING #{core.actions.select{|a| a.obsolete == false}.count} actions"
    core.actions.resolve_triggers.unapprovable.each.approve
    core.actions.resolve_triggers.approvable.each.approve

    # apply
    puts title "APPLYING #{core.actions.approved.count} actions"
    core.actions.approved.resolve_dependencies.each.apply
  end

  def check action

  end

  def approve action

  end

  def title text
    "\n================ #{text} ================\n\n"
  end
end
