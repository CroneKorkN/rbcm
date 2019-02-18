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

puts "-----------------------------------------------"

module RBCM
  @@app_path ||= File.expand_path(File.dirname(__FILE__))
  require "#{@@app_path}/cli.rb"
  require "#{@@app_path}/action/action.rb"
  [:lib, :project, :node, :action].each do |dir|
    Dir["#{@@app_path}/#{dir}/*.rb"].each {|file| require file }
  end
  
  class Core
    def initialize project_path
      @project_path = project_path
      @@app_path = File.expand_path(File.dirname(__FILE__)) 
      # get involved projects
      @projects = get_projects project_path
      puts "#  projects: " + @projects.collect(&:path).join(', ')
      # collect definitions
      @definitions = RBCM::DefinitionList.new @projects.each.definitions.flatten
      puts "#  capabilities: " + @definitions.type(:capability).collect(&:name).join(', ')
      # collect templates
      @templates = RBCM::TemplateList.new @projects.each.templates.flatten
      # create nodes
      @nodes = RBCM::NodeList.new get_nodes
      puts "#  nodes: " + @nodes.collect(&:name).join(', ')
      # parse node
      @nodes.each.parse
      # collect actions
      @actions = RBCM::ActionList.new @nodes.each.actions.flatten
      ######
      puts "#  stack: "
      @actions.each{|action| puts action.job.stack.collect(&:to_s).join(" > ")}
      
      puts "#  apply"
      @actions.resolve.each do |action| 
        print action.job.stack.collect(&:to_s).join(" > ")
        print "    "
        puts "#  blocker #{action.blocker.reasons}"
        
      end
      ######
      #@dispatcher = RBCM::ActionDispatch.new
      #@dispatcher.run @actions
    end
    
    attr_reader :definitions
    
    def apply
      @actions.each.apply
    end
    
    private
    
    def get_projects path
      main_project = RBCM::Project.new path
      [ RBCM::Addon.new(type: :dir, name: "#{@@app_path}/capabilities"),
        main_project,
        *main_project.addons
      ].flatten
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
