require file

class Node
  def initialize name
    @jobs = []
    @commands = []
    import_capabilities
  end

  def add_job job
    @jobs.append! job
  end

  def apply node
    # collect commands
    @jobs.collect {call}
    @commands.collect {run_at_node}
  end

  def run command
    @commands << command
  end

  private

  def run_at_node
    # ssh ....
  end
end
