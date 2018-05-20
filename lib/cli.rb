class CLI
  def initialize core, params
    options = Options.new params

    # parse
    puts title "RBCM starting", first: true
    core.parse

    # check
    puts title "CHECKING #{core.nodes.count} nodes"
    core.actions.each do |action|
      check action
    end

    # approve
    puts title "APPROVING #{core.actions.select{|a| a.obsolete == false}.count} actions"
    core.actions.resolve_triggers.unapprovable.each do |action|
      approve action
    end
    core.actions.resolve_triggers.approvable.each do |action|
      approve action
    end

    # apply
    puts title "APPLYING #{core.actions.approved.count} actions"
    core.actions.approved.resolve_dependencies.each do |action|
      apply action
    end
  end

  def check action
    puts "│ CHECKING $>_ #{action.check}"
    action.check!
  end

  def approve action
    action.approve
  end

  def apply action

  def title text, first: false
    "\n\e[7m\e[1m#{" "*16}#{text}#{" "*16}\e[0m"
  end
end
