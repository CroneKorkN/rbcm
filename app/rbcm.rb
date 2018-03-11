 #!/usr/local/bin/ruby

 require './lib.rb'

 class RBCM
  def initialize
    Node.load_capabilities
    @nodes = {}
    # collects collections from nodes with regex patterns to be apllied after all nodes are collected
    @patterns = {}
    Dir["../config/nodes/**/*.rb"].each do |file|
      self.instance_eval File.read(file)
    end
    @patterns.each do |pattern, collection|
      @nodes.each do |name, node|
        node.add_collection collection if name.match /#{pattern}/
      end
    end
  end

  def nodes names=nil
    return @nodes unless names
    collection = Proc.new # Proc.new without paramaters catches a given block
    [names].flatten.each do |name|
      @patterns[name] = collection and next if name.class == Regexp
      @nodes[name] = Node.new name unless @nodes[name]
      @nodes[name].add_collection collection
    end
  end

  def render
    @nodes.each do |name, node|
      node.render
    end
    self
  end

  def apply
    # scp, ssh
  end

  def clear_cache
    FileUtils.rm_rf Dir.glob("#{dir_path}/*") if dir_path.present?
  end
end

with Time.now do
  rbcm = RBCM.new
  rbcm.render
  pp rbcm.nodes
  log "rbmc took #{Time.now - self}"
end
