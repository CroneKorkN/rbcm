class RBCM
  def initialize
    Node.populate
    @nodes = {}
    # collects jobs from nodes with regex patterns to be apllied after all nodes are collected
    @patterns = {}
    Dir["../config/nodes/**/*.rb"].each do |file|
      require file
    end
  end

  def nodes names
    job = Proc.new # Proc.new without paramaters catches the given block
    [names].flatten.each do |name|
      @patterns << job and continue if node_name.class == Rebexp
      @nodes[name] = Node.new name unless @nodes[name]
      @nodes[name].add_job job
    end
  end

  def apply
    @nodes.collect {apply}
  end
end

RBCM.new.apply
