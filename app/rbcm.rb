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

class RBCM::Core
  def initialize path
    load_files
    # get involved projects
    @projects = get_projects path
    # collect definitions
    @definitions = RBCM::DefinitionList.new @projects.each.definitions.flatten
    # collect templates
    @templates = RBCM::TemplateList.new @projects.each.templates.flatten
    # create nodes
    @nodes = get_nodes
    # create groups
    @groups = get_nodes
    # parse node
    #@nodes.each.parse
    # collect actions
    #@actions = RBCM::ActionList.new @nodes.each.actions
  end
  
  def apply
    @actions.each.apply
  end
  
  private
  
  def load_files
    app_dir = File.expand_path File.dirname(__FILE__)
    Dir["#{app_dir}/lib/*.rb"].each {|file| require file }
    Dir["#{app_dir}/project/*.rb"].each {|file| require file }
  end
  
  def get_projects path
    main_project = Project.new path
    [
      RBCM::Addons.new(type: :dir, name: "./capabilities"),
      main_project,
      *main_project.recursive_addons.flatten
    ]
  end
  
  def get_nodes
    definitions.type(:node).collect do |node_definition|
      node = nodes[node_definition.name] ||= RBCM::Node.new(
        project: self,
        name: node_definition.name,
        project_file: node_definition.project_file
      )
      node.jobs.append RBCM::Job.new type: :node, name: node_definition.name
      # apply pattern definitions to node
      definitions(:pattern).select { |pattern_definition|
        node_definition.name =~ /#{pattern_definition.name}/
      }.each do |pattern_definition|
        node.jobs.append RBCM::Job.new type: :pattern, name: pattern_definition.name
      end
      [node.name, node]
    end.to_h
  end
  
  def get_groups
    # create groups
    groups = RBCM::ArrayHash.new
    @project.definitions(:group).each do |group_definition|
      groups[group_definition.name].append RBCM::Job.new type: :group, name: group_definition.name
    end
    groups
  end
end
