require "net/ssh"
require "net/scp"
require "fileutils"
require "shellwords"
require "diffy"
require "optparse"
require "parallel"
require "yaml"

require "pry"

APPDIR = File.expand_path File.dirname(__FILE__)
[ :lib, :action, :file_system, :action_file, :node, :capability,
  :action_list, :action_command, :job, :remote, :sandbox, :array_hash, :params,
  :template, :rbcm, :options, :cli, :definition, :project, :project_file,
  :project_file_capabilities
].each{|requirement| require "#{APPDIR}/#{requirement}.rb"}

class RBCM
  def initialize project_path, interactive: true
    # initialize project
    @project = Project.new project_path
    # create nodes
    @group_additions = ArrayHash.new
    @nodes = {}
    @project.definitions(:node).each do |node_definition|
      @nodes[node_definition.name] ||= Node.new self, node_definition.name
      @nodes[node_definition.name] << node_definition
      # apply pattern definitions to node
      @nodes[node_definition.name] << @project.definitions(:pattern).collect do |pattern_definition|
         pattern_definition if node_definition.name =~ /#{pattern_definition.name}/
      end
    end
    # create groups
    @groups = ArrayHash.new
    @project.definitions(:group).each do |group_definition|
      @groups[group_definition.name] << group_definition
    end
    # else
    # tell project path to template class
    Template.project_path = @project.path
    # interactively?
    return if interactive
    parse
    actions.each.check
    actions.each.apply
  end

  attr_reader   :nodes, :groups, :project, :actions
  attr_accessor :group_additions

  def actions
    ActionList.new nodes.values.each.actions.flatten(1)
  end

  def jobs
    nodes.values.each.jobs.flatten(1)
  end

  def parse
    # parse definitions
    log "parsing nodes"
    nodes.values.each.parse

    # parse group additions
    log "parsing additions"
    nodes.values.each do |node|
      node.sandbox.evaluate node.additions
    end
    # parse final capabilities
    log "parsing 'cap!'"
    nodes.values.each do |node|
      node.capabilities.each{|capability| node.sandbox.send "#{capability}!"}
    end
  end
end
