 #!/usr/local/bin/ruby

 require './node.rb'

 class RBCM
  def initialize
    Node.load_capabilities
    @nodes = {}
    # collects jobs from nodes with regex patterns to be apllied after all nodes are collected
    @patterns = {}
    Dir["../config/nodes/**/*.rb"].each do |file|
      self.instance_eval File.read(file)
    end
  end

  def nodes names
    job = Proc.new # Proc.new without paramaters catches a given block
    [names].flatten.each do |name|
      @patterns[name] = job and next if name.class == Regexp
      @nodes[name] = Node.new name unless @nodes[name]
      @nodes[name].add_job job
    end
  end

  def apply
    @nodes.each do |name, node|
      @nodes[name] = node.apply
    end
  end
end

rbcm = RBCM.new
p "APPLY"
rbcm.apply
