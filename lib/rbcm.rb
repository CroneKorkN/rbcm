require "net/ssh"
require "net/scp"
require "fileutils"
require "shellwords"
require "diffy"

APPDIR = File.expand_path File.dirname(__FILE__)
[ :lib, :action, :definition_file, :file_system, :file_action, :node,
  :command_list, :command, :job, :remote, :sandbox, :array_hash
].each{|requirement| require "#{APPDIR}/#{requirement}.rb"}

class RBCM
  attr_reader :nodes, :groups
  attr_accessor :group_additions

  def initialize project_path
    @patterns = {}
    @nodes = {}
    @groups = ArrayHash.new
    @group_additions = ArrayHash.new
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
        @groups[name] << definition
      end
      @patterns << definition_file.patterns
      definition_file.nodes.each do |name, definition|
        @nodes[name] ||= Node.new self, name
        @nodes[name] << definition
      end
    end
    @patterns.each do |pattern, definition|
      @nodes.select{|name, node| name =~ /#{pattern}/}.each do |name, node|
        node << definition
      end
    end
  end

  def parse
    # parse base definitions
    log "parsing nodes"
    nodes.values.each.parse
    # parse cross-definitions
    log "parsing additions"
    nodes.values.each do |node|
      node.sandbox.evaluate node.additions
    end
    # apply final capabilities
    log "appling 'cap!'"
    nodes.values.each do |node|
      node.capabilities.each do |capability|
        node.sandbox.send "#{capability}!"
      end
    end
  end

  def approve
    nodes.values.each.check
    commands.each.extend(CommandList).approve
    #while approvable = commands.select{|c| c.obsolete == false and c.approved == nil}
    #  approvable.first.approve if approvable.any?
    #end
  end

  def commands
    nodes.values.each.commands.flatten(1)
  end

  def apply
    puts "\n======== APPLYING #{commands.select.approved.count} ========\n\n"
    commands.select.approved.extend(CommandList).resolve_dependencies.each.apply
  end
end
