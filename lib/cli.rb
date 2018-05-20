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
    core.actions.resolve_triggers.unapprovable.each.approve
    core.actions.resolve_triggers.approvable.each.approve

    # apply
    puts title "APPLYING #{core.actions.approved.count} actions"
    core.actions.approved.resolve_dependencies.each.apply
  end

  def check action
    puts "│ CHECKING $>_ #{action.check}"
    action.check!
  end

  def approve action

  end

  def title text, first: false
    [ first ? nil : "└────────#{"─"*text.length}────────\n",
      "\n┌────────#{"─"*text.length}────────┐",
      "\n│         \e[1m#{text}\e[0m       │",
      "\n├────────#{"─"*text.length}────────┘",
    ].join
  end
end
