class Command < Action
  attr_reader :line, :params, :dependencies, :obsolete,
              :approved, :triggered_by, :chain, :capability, :node, :trigger

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
    @trigger = trigger + [chain.last]
    @triggered_by = triggered_by
  end

  def check
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
end
