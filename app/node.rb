require file

class Node
  def initialize name
    @jobs = []
    # include all recipies
    Dir[
      File.join(File.dirname(__FILE__), '..', 'lib') + "**/*.rb"
    ].each { |file|
      include self.class.const_get(
        File.basename(file).gsub('.rb', '').split("_").map{|ea| ea.capitalize}.to_s
      )
    }
  end

  def add_job job
    @jobs.append! job
  end

  def apply node
    @jobs.each do |job|
      job.call
    end
  end

  def run
    # run terminal command on node
  end
end
