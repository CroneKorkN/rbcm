class Node
  attr_reader :jobs, :definitions

  def initialize
    @definitions = []
  end

  def << definition
    @definitions << definition
  end

  def jobs
    @jobs ||= @definitions.collect{|definition| definition.jobs}
  end

  def commands
    @commands ||= CommandCollector.new(self).jobs.extend(CommandList).resolve
  end
end
