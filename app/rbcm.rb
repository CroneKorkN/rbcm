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
[ "action/action", "action/command", "action/file", "action/list",
  "lib/array_hash", "lib/lib", "node/node", "node/file", "node/job",
  "node/filesystem", "node/remote", "node/sandbox", "node/template",
  "lib/options", "lib/quick_each",
  "lib/params", "project/project", "project/definition", "project/file",
  "project/capability", "project/sandbox", "cli"
].each{|requirement| require "#{APPDIR}/#{requirement}.rb"}

class RBCM
  def initialize project_path
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
    Node::Template.project_path = @project.path
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
    log "parsing nodes"
    nodes.values.each.parse
    log "parsing additions"
    nodes.values.each do |node|
      node.sandbox.evaluate node.additions
    end
    log "parsing 'cap!'"
    nodes.values.each do |node|
      node.capabilities.each{|capability| node.sandbox.send "#{capability}!"}
    end
  end
end