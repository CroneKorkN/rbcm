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
    @jobs.each do |job|
      # running a job returns bash to be executed on node later
      job.call
    end
    @commands.each do |command|
      # ssh and run command
    end
  end

  def run command
    @commands << command
  end

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
