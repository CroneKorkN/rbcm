class Command < Action
  attr_reader :line

  def initialize node:, line:, params:, dependencies:,
      check: nil, chain:, trigger: nil, triggered_by: nil
    @chain = chain
    @capability = chain.last
    @node = node
    @line = line
    @params = params
    @dependencies = [:file] + [dependencies].flatten - [chain.last]
    @check = check
    @obsolete = nil
    @approved = nil
    @trigger = [trigger, chain.last].flatten.compact
    @triggered_by = [triggered_by].flatten.compact
  end

  def check
    puts "============="
    p @trigger
    p @triggered_by
    puts "----------"

    if @check
      log "CHECKING $>_ #{@check}"
      @obsolete = @node.remote.execute(@check).exitstatus == 0
    else
      @obsolete = false
    end
  end

  def diff
    "  $>_ \e[1m#{@line}\e[0m\e[2m#{" CHECK " if @check}#{@check}\e[0m"
  end

  def siblings
    @node.rbcm.actions.select{ |action|
      action.chain[1..-1] == @chain[1..-1] and action.line == @line
    } - [self]
  end

  def apply
    super @node.remote.execute(@line)
  end
end
