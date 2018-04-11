PWD = ARGV[0]
APPDIR = File.expand_path File.dirname(__FILE__)
require "fileutils"
[ :lib, :node_file, :node, :capabilities, :command_list, :command,
  :command_collector, :definition, :job, :remote
].each{|requirement| require "#{APPDIR}/#{requirement}.rb"}

class RBCM
  attr_reader :nodes

  def initialize
    @nodes = {}
    load!
    #run!
    #diff!
    #apply!
  end

  def load!
    # load project
    patterns = {}
    Dir["#{PWD}/nodes/**/*.rb"].each do |path|
      node_file = NodeFile.new(path)
      node_file.affected_nodes.each do |node_name|
        unless node_name.class == Regexp
          @nodes[node_name] = Node.new node_name unless @nodes[node_name]
          @nodes[node_name] << node_file.definition
        else
          patterns[node_name] = [] unless patterns[node_name]
          patterns[node_name] << node_file.definition
        end
      end
    end
    # apply patterns after all explicit definitions are loaded
    patterns.each do |pattern, definitions|
      definitions.each do |definition|
        @nodes.each do |name, node|
          node << definition if name.match /#{pattern}/
        end
      end
    end
  end
end

rbcm = RBCM.new
#puts rbcm.nodes.first[1].commands.collect{|command| command.line}.join("\n")
rbcm.nodes.each do |name, node|
 puts "=============================================================="
 puts name
 pp node.jobs
 puts node.commands
 node.affected_files.each do |file|
   puts node.remote.execute! "cat #{file}"
 end
 #puts node.commands
end
#pp rbcm
