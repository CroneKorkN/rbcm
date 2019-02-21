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
  [:lib, :project, :node, :action, :core].each do |dir|
    Dir["#{@@app_path}/#{dir}/*.rb"].each {|file| require file }
  end
  
  class Core
    def method_added name
      p "ADDEDDDD #{name} TO #{self}"
    end
        def initialize project_path
      @project_path = project_path
      @@app_path = File.expand_path(File.dirname(__FILE__)) 
      # get involved projects
      @projects = [ 
        RBCM::Addon.new(type: :dir, name: "#{@@app_path}/capabilities"),
        RBCM::Project.new(project_path) 
      ]
      
      @definitions = RBCM::DefinitionList.new @projects.each.definitions.flatten
      @jobs = RBCM::JobList.new @projects.each.jobs.flatten
      @actions = RBCM::ActionList.new

      @env = {
        rbcm: self,
        instance_variables: {},
        class_variables: {},
        jobs: @jobs,
        checks: [],
        actions: @actions,
        definitions: @definitions
      }
      @cache = {
        checks: {},
        targets: [],
        triggered: [],
      }
      
      p @definitions.count
      p "------------"
      p @jobs.status(:new).count
      p @jobs.status(:delayed).count
      p @jobs.status(:done).count
      
      while job = @jobs.status(:new).first || @jobs.status(:delayed).first
        job.run @env
      end

      p @definitions.count
      p @jobs.count
      
      p @actions.count

binding.pry
      
      
      # puts "#  projects: " + @projects.collect(&:path).join(', ')
      # # collect definitions
      # @definitions = RBCM::DefinitionList.new @projects.each.definitions.flatten
      # puts "#  capabilities: " + @definitions.type(:capability).collect(&:name).join(', ')
      # # collect templates
      # @templates = RBCM::TemplateList.new @projects.each.templates.flatten
      # # create nodes
      # @nodes = RBCM::NodeList.new get_nodes
      # puts "#  nodes: " + @nodes.collect(&:name).join(', ')
      # # parse node
      # @nodes.each.parse
      # # collect actions
      # @actions = RBCM::ActionList.new @nodes.each.actions.flatten
      # ######
      # puts "#  stack: "
      # @actions.each{|action| puts action.job.stack.collect(&:to_s).join(" > ")}
      # 
      # puts "#  run: "
      # @actions.resolve.each do |action| 
      #   print action.job.stack.collect(&:to_s).join(" > ")
      #   if action.blocker.reasons.any?
      #     puts " # blocker #{action.blocker.reasons}"
      #   else
      #     puts action.run!
      #   end
      # end
    end
    
    attr_accessor :actions, :definitions, :jobs, :projects
    
    private
    
    def get_projects path
      [ RBCM::Addon.new(type: :dir, name: "#{@@app_path}/capabilities"),
        RBCM::Project.new(path) 
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
        # run pattern definitions to node
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
