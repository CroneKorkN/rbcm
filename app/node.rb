require file

class Node
  def initialize name
    @jobs = []
    @commands = []
    import_recipes
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

  #TODO require recipes on domand on NameError
  def import_recipes
    Dir[
      File.join(File.dirname(__FILE__), '..', 'lib') + "**/*.rb"
    ].each { |file|
      include self.class.const_get(
        File.basename(file).gsub('.rb', '').split("_").map{|ea| ea.capitalize}.to_s
      )
    }
  end
end
