class Node
  attr_reader :jobs

  def initialize
    @jobs = []
  end

  def << jobs
    @jobs += jobs
  end

  def commands
    @commands ||= @jobs.collect {|job|
      job.commands self
    }.flatten.extend(CommandList).resolve
  end
end
