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
    @capabilities = Definition.capabilities
    import_definitions "#{project_path}definitions"
    @groups = Group.all
  end

  def parse
    nodes.each_value{|node| node.parse}
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
    Dir["#{definitions_path}/**/*.rb"].collect{ |definition_file_path|
      DefinitionFile.new definition_file_path
    }.each do |definition_file|
      definition_file.groups.each do |name, definition|
        Group[name] = definition
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
    @commands ||= nodes.each.commands
  end
end
