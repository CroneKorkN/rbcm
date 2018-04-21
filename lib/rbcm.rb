require "quickeach"

PWD = ARGV[0]
APPDIR = File.expand_path File.dirname(__FILE__)
require "fileutils"
[ :lib, :definition_file, :node, :group, :command_list,
  :command, :definition, :job, :remote
].each{|requirement| require "#{APPDIR}/#{requirement}.rb"}

class RBCM
  attr_reader :nodes, :groups, :project_path

  def initialize project_path
    @patterns = {}
    @nodes = {}
    @groups = {}
    import_definitions "#{project_path}definitions"
  end

  def parse
    nodes.each.parse
  end

  def approve
    commands.each.approve
  end

  def apply
    commands.each.apply
  end

  private

  def import_capabilities
    #auto
  end

  def import_definitions definitions_path
    p `ls #{definitions_path}`
    p Dir["#{definitions_path}/**/*.rb"]
    Dir["#{definitions_path}/**/*.rb"].collect{ |definition_file_path|
      DefinitionFile.new definition_file_path
    }.each do |definition_file|
      definition_file.groups.each do |definition|
        Group << definition
      end
      @patterns << definition_file.patterns
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

  private

  def commands
    @commands ||= nodes.collect{|node| node.commands}
  end
end
