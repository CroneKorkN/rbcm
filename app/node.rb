class Node
  attr_reader :jobs, :definitions

  def initialize
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

  def affected_files
    @affected_files ||= jobs.select{ |job|
      job.capability == :file
    }.collect{ |job|
      job.ordered_params[0] || nil
    }
  end
end
