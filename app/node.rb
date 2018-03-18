class Node
  def initialize
    @jobs = []
  end

  def << jobs
    @jobs += jobs.flatten
  end

  def commands
    @commands ||= @jobs.collect {|job|
      job.commands
    }.flatten.extend(CommandList).resolve
  end
end
