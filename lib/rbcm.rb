PWD = ARGV[0]
APPDIR = File.expand_path File.dirname(__FILE__)
require "fileutils"
[ :lib, :definition_file, :node, :capabilities, :command_list, :command,
  :command_collector, :definition, :job, :remote
].each{|requirement| require "#{APPDIR}/#{requirement}.rb"}

class RBCM
  attr_reader :nodes, :groups, :project_path

  def initialize project_path
    @patterns = {}
    @nodes = {}
    @groups = {}
    load_project project_path
  end

  private

  def load_project project_path
    patterns = {}
    Dir["#{project_path}/nodes/**/*.rb"].each do |definition_file_path|
      definition_file = DefinitionFile.new(definition_file_path)
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
