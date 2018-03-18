class Node
  def initialize
    @jobs = []
    @commands = CommandList.new
  end

  def << jobs
    @jobs += jobs.flatten
  end

  def run!
    @jobs.each {|job| @commands += job.commands}
  end
end
