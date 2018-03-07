class RBCM
  def initialize
    @nodes = {}
    # collects jobs from nodes with regex patterns to be apllied after all nodes are collected
    @patterns = {}
    Dir["..config/nodes/**/*.rb"].each do |file|
      require file
    end
    # populate node
    Dir['../config/capabilities/*.rb'].each do |path|
      load 'path'
      method_name = File.basename path, '.rb'
      Node.send :define_method, :method_name, lambda(&method method_name.to_symbol)
    end
  end

  def node names
    job = Proc.new # Proc.new without paramaters catches the given block
    [names].flatten.each do |name|
      pattern name, job and continue if node_name.class == Rebexp
      @nodes[name] = Node.new name unless @nodes[name]
      @nodes[name].add_job job
    end
  end

  def pattern node_name, job
    @patterns[node_name] = [] unless @patterns[node_name]
    @patterns[node_name] << job
  end

  def apply
    @nodes.collect {apply}
  end
end

RBCM.new.apply
