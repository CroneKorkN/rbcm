require "net/ssh"
require "net/scp"
require "fileutils"
require "shellwords"
require "diffy"
require "optparse"
require "parallel"
require "yaml"

APPDIR = File.expand_path File.dirname(__FILE__)
[ :lib, :action, :definition_file, :file_system, :action_file, :node,
  :action_list, :action_command, :job, :remote, :sandbox, :array_hash, :params,
  :template, :rbcm, :options, :cli, :definition, :project, :project_file
].each{|requirement| require "#{APPDIR}/#{requirement}.rb"}

class RBCM
  attr_reader :nodes, :groups, :project_path
  attr_accessor :group_additions, :actions

  def initialize project_path
    @project = Project.new project_path
    p @project.nodes.each.keys.flatten

    @project_path = project_path
    @patterns = {}
    @nodes = {}
    @groups = ArrayHash.new
    @group_additions = ArrayHash.new
    import_capabilities "#{project_path}/capabilities"
    import_definitions "#{project_path}/definitions"
    Template.project_path = project_path
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
    log "parsing 'cap!'"
    nodes.values.each do |node|
      node.capabilities.each{|capability| node.sandbox.send "#{capability}!"}
    end
  end

  def actions
    ActionList.new nodes.values.each.actions.flatten(1)
  end

  def jobs
    nodes.values.each.jobs.flatten(1)
  end
end
