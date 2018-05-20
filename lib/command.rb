class Command < Action
  attr_reader :line

  def check!
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
