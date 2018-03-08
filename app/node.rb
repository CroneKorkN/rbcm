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

  def self.load_capabilities
    Dir['../config/capabilities/*.rb'].each do |path|
      load 'path'
      method_name = File.basename path, '.rb'
      self.define_method, :method_name, lambda(&method method_name.to_symbol)
    end
  end
end
