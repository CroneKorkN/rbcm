require "net/ssh"
require "net/scp"
require "fileutils"
require "shellwords"
require "diffy"

APPDIR = File.expand_path File.dirname(__FILE__)
[ :lib, :definition_file, :file_system, :node, :group, :command_list,
  :command, :job, :remote, :sandbox, :group_list
].each{|requirement| require "#{APPDIR}/#{requirement}.rb"}

class RBCM
  attr_reader :nodes, :groups
  attr_accessor :group_additions

  def initialize project_path
    @patterns = {}
    @nodes = {}
    @group_additions = {}
    import_capabilities "#{project_path}/capabilities"
    import_definitions "#{project_path}/definitions"
  end

  def import_capabilities capabilities_path
    Sandbox.import_capabilities capabilities_path
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
        @nodes[name] = Node.new self, name unless @nodes[name]
        @nodes[name] << definition
      end
    end
    @patterns.each do |pattern, definition|
      @nodes.find(/#{pattern}/).each do |node|
        node << definition
      end
    end
  end

  def parse
    # parse base definitions
    nodes.values.each.parse
    p 222222222222
    p group_additions
    # parse cross-definitions
    nodes.values.each do |node|
      node.sandbox.evaluate node.additions
    end
    # apply final capabilities
    nodes.values.each do |node|
      node.capabilities.each do |capability|
        node.sandbox.send "#{capability}!"
      end
    end
  end

  def approve
    nodes.values.each.check
    nodes.values.each.approve
    #while approvable = commands.select{|c| c.obsolete == false and c.approved == nil}
    #  approvable.first.approve if approvable.any?
    #end
  end

  def commands
    nodes.values.each.commands.flatten(1)
  end

  def apply
    puts "\nAPPLYING\n\n"
    commands.select{|c| c.approved}.each.apply
  end
end
