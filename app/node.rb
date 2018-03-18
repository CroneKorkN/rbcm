class Node
  def initialize
    @jobs = []
  end

  def << job
    @jobs << job
  end

  def run
    @jobs.each {|job| job.run!}
  end
end
