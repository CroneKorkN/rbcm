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
    @@app_path = File.expand_path(File.dirname(__FILE__))

    def initialize project_path
      @project_path = project_path
    end
    
    def actions
      RBCM::ActionList.new nodes.collect(&:actions).flatten
    end
    
    def nodes
      @nodes ||= RBCM::NodeList.new \
        jobs.capability(:node).collect{|j| j.params.first}.uniq.collect{ |name| 
          RBCM::Node.new rbcm: self, name: name
        }
    end
    
    def jobs
      unless @jobs
        @jobs = RBCM::JobList.new projects.each.jobs.flatten
        @env = {
          rbcm: self,
          instance_variables: {},
          class_variables: {},
          jobs: @jobs,
          checks: [],
          definitions: definitions
        }
        while job = @jobs.status(:new).first || @jobs.status(:delayed).first
          job.run @env
        end
      end
      @jobs
    end
    
    def definitions
      @definitions ||= RBCM::DefinitionList.new projects.each.definitions.flatten
    end
    
    def projects
      @projects ||= [ 
        RBCM::Project.new("#{@@app_path}/capabilities"),
        RBCM::Project.new(@project_path),
      ]
    end
    
    attr_accessor :actions
    attr_writer :projects, :definitions, :jobs
  end
end
