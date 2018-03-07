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
      begin
        job.call
      rescue NameError => e
        #TODO get failed method name
        #TODO prevent from calling commands twice, that were fired before failure
        require "../config/recipes/failed_method_anme.rb"
        job.call # populates @commands bei calling 'run'
      end
    end
    @commands.each do |command|
      # ssh and run command
    end
  end

  def run command
    @commands << command
  end

  # require in demand maybe?
  #def import_recipes
  #  Dir[
  #    File.join(File.dirname(__FILE__), '..', 'lib') + "**/*.rb"
  #  ].each { |file|
  #    include self.class.const_get(
  #      File.basename(file).gsub('.rb', '').split("_").map{|ea| ea.capitalize}.to_s
  #    )
  #  }
  #end
end
