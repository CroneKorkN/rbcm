class Command < Action
  attr_reader :line

  # determine wether the command is neccessary
  def check!
    return if @obsolete != nil
    if @check
      @obsolete = @node.remote.execute(@check).exitstatus == 0
    else
      @obsolete = false
    end
  end

  def neccessary?
    check!
    not @obsolete
  end

  # matching commands on  other nodes to be approved at once
  def siblings
    @node.rbcm.actions.select{ |action|
      action.chain[1..-1] == @chain[1..-1] and action.line == @line
    } - [self]
  end

  # execute the command remote
  def apply!
    @applied = true
    @result = @node.remote.execute(@line)
  end
end
