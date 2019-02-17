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

module RBCM
  class Core
    def initialize path
      load_files
      # get involved projects
      @projects = get_projects path
      # collect definitions
      @definitions = RBCM::DefinitionList.new @projects.each.definitions.flatten
      # collect templates
      @templates = RBCM::TemplateList.new @projects.each.templates.flatten
      # create nodes
      @nodes = RBCM::NodeList.new get_nodes
      # parse node
      @nodes.each.parse
      # collect actions
      @actions = RBCM::ActionList.new @nodes.each.actions.flatten
      #binding.pry
    end
    
    attr_reader :definitions
    
    def apply
      @actions.each.apply
    end
    
    private
    
    def load_files
      app_dir = File.expand_path(File.dirname(__FILE__)) 
      Dir["#{app_dir}/lib/*.rb"].each {|file| require file }
      Dir["#{app_dir}/project/*.rb"].each {|file| require file }
      Dir["#{app_dir}/node/*.rb"].each {|file| require file }
      require "#{app_dir}/action/action.rb"
      Dir["#{app_dir}/action/*.rb"].each {|file| require file }
    end
    
    def get_projects path
      main_project = Project.new path
      [
        RBCM::Addon.new(type: :dir, name: "#{File.expand_path(File.dirname(__FILE__))}/capabilities"),
        main_project,
        *main_project.addons.flatten
      ]
    end
    
    def get_nodes
      @definitions.type(:node).collect do |node_definition|
        node = RBCM::Node.new(
          rbcm: self,
          name: node_definition.name,
          project_file: node_definition.project_file
        )
        node.jobs.append RBCM::Job.new type: :node, name: node_definition.name
        # apply pattern definitions to node
        @definitions.type(:pattern).select { |pattern_definition|
          node_definition.name =~ /#{pattern_definition.name}/
        }.each do |pattern_definition|
          node.jobs.append RBCM::Job.new type: :pattern, name: pattern_definition.name
        end
        node
      end
    end
  end
end
