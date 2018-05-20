class Command < Action
  attr_reader :line

  def check!
    if @check
      @obsolete = @node.remote.execute(@check).exitstatus == 0
    else
      @obsolete = false
    end
  end

  def siblings
    @node.rbcm.actions.select{ |action|
      action.chain[1..-1] == @chain[1..-1] and action.line == @line
    } - [self]
  end

  def apply!
    @node.remote.execute(@line)
  end
end
