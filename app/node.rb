class Node
  def initialize
    @jobs = []
    @commands = CommandList.new
  end

  def << job
    @jobs << job
  end

  def run!
    p @jobs.flatten.count
    @jobs.flatten.each {|job| @commands += job.commands}
  end
end
