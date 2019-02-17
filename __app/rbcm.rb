module RBCM
  require "net/ssh"
  require "net/scp"
  require "fileutils"
  require "shellwords"
  require "diffy"
  require "pry"
  require "git"
  require 'openssl'
  require 'base64'
  require 'ipaddress'
  require 'unix_crypt'

  APPDIR = File.expand_path File.dirname(__FILE__)
  [ "action/action",    "action/command",
    "action/file",      "action/list",
    "node/node",        "node/file",
    "node/job",         "node/filesystem",
    "node/remote",      "node/sandbox",
    "node/job_search",
    "lib/lib",          "lib/array_hash",
    "lib/options",      "lib/quick_each",
    "lib/params",       "lib/encrypt",
    "lib/binding",
    "project/project",  "project/definition",
    "project/file",     "project/capability",
    "project/sandbox",  "project/addon",
    "project/template", "project/template_list",
    "cli"
  ].each{|requirement| require "#{APPDIR}/#{requirement}.rb"}

  class Core
    def initialize project_path
      # initialize project
      @project = RBCM::Project.new project_path
      # create nodes
      @group_additions = RBCM::ArrayHash.new
      @nodes = {}
      @project.definitions(:node).each do |node_definition|
        @nodes[node_definition.name] ||= RBCM::Node.new(
          self,
          node_definition.name,
          node_definition.project_file.path
        )
        @nodes[node_definition.name] << node_definition
        # apply pattern definitions to node
        @nodes[node_definition.name] << @project.definitions(:pattern).collect do |pattern_definition|
           pattern_definition if node_definition.name =~ /#{pattern_definition.name}/
        end
      end
      # create groups
      @groups = RBCM::ArrayHash.new
      @project.definitions(:group).each do |group_definition|
        @groups[group_definition.name] << group_definition
      end
    end

    attr_reader   :nodes, :groups, :project, :actions
    attr_accessor :group_additions, :user_password

    def providers
      nodes.values.each.providers.flatten(1)
    end

    def actions
      RBCM::ActionList.new nodes.values.each.actions.flatten(1)
    end

    def jobs
      nodes.values.each.jobs.flatten(1)
    end

    def parse
      # parsing nodes
      nodes.values.each.parse
      # parsing additions
      nodes.values.each do |node|
        node.sandbox.evaluate node.additions
      end
      # parsing 'cap!'
      nodes.values.each do |node|
        node.capabilities.each{|capability| node.sandbox.send "#{capability.name}!"}
      end
    end

    def check! &block
      Net::SSH::Multi.start do |session|
        session.via 'gateway', 'gateway-user'
        @nodes.each do |name, node|
          session.group name.to_sym do
            session.use "#{name}"
          end
        end
        actions.checkable.each do |action|
          actions.check.each do |check|
            session.with(action.job.node.name.to_sym).exec check &block
          end
        end
        session.loop
      end
    end
  end
end
