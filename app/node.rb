class Node
  attr_reader :jobs, :definitions

  def initialize name
    @name = name
    @definitions = []
  end

  def << definition
    @definitions << definition
  end

  def jobs
    @jobs ||= @definitions.collect{|definition| definition.jobs}.flatten
  end

  def commands
    @commands ||= CommandCollector.new(self).commands.extend(CommandList).resolve
  end

  def diff
    # local vs remote state
  end

  def state
    # local state
    
  end

  def remote
    @remote ||= Remote.new @name
  end

  def affected_files
    @affected_files ||= commands.select{ |command|
      command.capability == :file
    }.collect{ |command|
      command.ordered_params.first
    }
  end
end
