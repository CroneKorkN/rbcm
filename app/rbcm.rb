 #!/usr/local/bin/ruby

 require './node.rb'

 class RBCM
  def initialize
    Node.load_capabilities
    @nodes = {}
    # collects jobs from nodes with regex patterns to be apllied after all nodes are collected
    @patterns = {}
    Dir["../config/nodes/**/*.rb"].each do |file|
      env.instance_eval(File.read(file))
    end
  end

  def nodes names
    job = Proc.new # Proc.new without paramaters catches the given block
    [names].flatten.each do |name|
      @patterns[name] = job and continue if node_name.class == Rebexp
      @nodes[name] = Node.new name unless @nodes[name]
      @nodes[name].add_job job
    end
  end

  def apply
    @nodes.collect {apply}
  end
end

def nodes names
  puts names
end


RBCM.new.apply
