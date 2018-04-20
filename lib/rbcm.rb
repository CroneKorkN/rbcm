require "fileutils"
APPDIR = File.expand_path File.dirname(__FILE__)
[ :lib, :node_file, :node, :capabilities, :command_list, :command,
  :command_collector, :definition, :job, :remote
].each{|requirement| require "#{APPDIR}/#{requirement}.rb"}

class RBCM
  attr_reader :nodes, :project_path

  def initialize project_path
    @nodes = {}
    @project_path = project_path
  end

  def load
    patterns = {}
    Dir["#{@project_path}/nodes/**/*.rb"].each do |path|
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

  def approve
  end

  def apply
  end
end

RBCM.new 23525
#rbcm.approve
#rbcm.apply
