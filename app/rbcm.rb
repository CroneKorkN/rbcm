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
    def initialize project_path
      @project_path = project_path
    end
    
    attr_writer :projects, :definitions, :jobs
    
    def actions
      RBCM::ActionList.new nodes.collect(&:actions).flatten
    end
    
    def nodes
      run_jobs if jobs.pending
      @nodes ||= RBCM::NodeList.new \
        jobs.node_names.collect{|name| RBCM::Node.new rbcm: self, name: name}
    end
    
    def run_jobs
      while job = RBCM::JobList.new(projects.collect(&:stack).flatten).pending.first
        job.run 
      end
    end
    
    def jobs
      RBCM::JobList.new projects.collect(&:stack).flatten
    end
    
    def definitions
      RBCM::DefinitionList.new projects.collect(&:definitions).flatten
    end
    
    def projects
      @projects ||= [ 
        RBCM::Project.new("#{File.expand_path(File.dirname(__FILE__))}/capabilities", rbcm: self),
        RBCM::Project.new(@project_path, rbcm: self),
      ]
    end
  end
end
