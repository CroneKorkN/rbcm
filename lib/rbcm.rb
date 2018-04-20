PWD = ARGV[0]
APPDIR = File.expand_path File.dirname(__FILE__)
require "fileutils"
[ :lib, :definition_file, :node, :capabilities, :command_list, :command,
  :command_collector, :definition, :job, :remote
].each{|requirement| require "#{APPDIR}/#{requirement}.rb"}

class RBCM
  attr_reader :nodes, :groups, :project_path

  def initialize project_path
    @project_path = project_path
    @patterns = {}
    @nodes = {}
    @groups = {}
    load!
    #run!
    #diff!
    #apply!
  end

  def load!
    patterns = {}
    Dir["#{PWD}/nodes/**/*.rb"].each do |path|
      definition_file = DefinitionFile.new(path)
      @groups += definition_file.groups
      @patterns += definition_file.patterns
      definition_file.nodes.each do |name, definition|
        @nodes[name] = Node.new name unless @nodes[name]
        @nodes[name] << definition
      end
    end
    @patterns.each do |pattern, definition|
      @nodes.find(/#{pattern}/).each do |node|
        node << definition
      end
    end
  end
end

rbcm = RBCM.new ARGV[0]
#puts rbcm.nodes.first[1].commands.collect{|command| command.line}.join("\n")
rbcm.nodes.each do |name, node|
 puts "=============================================================="
 puts name
 pp node.jobs
 puts node.commands
 p node.affected_files
 #puts node.commands
end
#pp rbcm
