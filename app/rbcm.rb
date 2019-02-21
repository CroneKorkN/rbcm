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
      @projects = [ 
        RBCM::Project.new("#{@@app_path}/capabilities"),
        RBCM::Project.new(project_path),
      ]
      @definitions = RBCM::DefinitionList.new @projects.each.definitions.flatten
      @jobs = RBCM::JobList.new @projects.each.jobs.flatten
      @actions = RBCM::ActionList.new

      # run jobs
      @env = {
        rbcm: self,
        instance_variables: {},
        class_variables: {},
        jobs: @jobs,
        checks: [],
        actions: @actions,
        definitions: @definitions
      }
      while job = @jobs.status(:new).first || @jobs.status(:delayed).first
        job.run @env
      end

      # projects
      puts "-- projects (#{@projects.count}) --\n#{@projects.collect(&:path)}"
            
      # definitions
      puts "-- definitions (#{@definitions.count}) --\n#{@definitions.collect(&:to_s)}"
            
      # jobs
      puts "-- jobs (#{@jobs.count}) --"
      @jobs.select{|finishing| @jobs.none?{|job| job.parent == finishing}}.each do |job|
        puts job.trace.collect(&:to_s).join(" > ")
      end
      
      # init cache
      @cache = {
        checks: {},
        targets: [],
        triggered: [],
      }
    end
    
    attr_accessor :actions, :definitions, :jobs, :projects
  end
end
