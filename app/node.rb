class Node
  attr_reader :name
  attr_accessor :capability_cache
  c = instance_methods
  include Capabilities
  p (instance_methods - c)

  def initialize name
    @name = name
    @cache_path = "#{File.dirname(__FILE__)}/cache/#{@name}"
    @definitions = [] # Procs from node files
    @capability_cache = nil # save the capability name of the job executed now
    @dependency_cache = [] # save the dependencies through each definition
    @jobs = [] # saves all parameters passed to caps
    @commands = []
  end

  def << definition
    @definitions << definition
  end

  def render
    # definition are executed, collecting @jobs
    @definitions.each do |definition|
      instance_exec &definition
    end
    @jobs.each do |job|
      job.run
      @dependency_cache = []
    end
    # order commands: solve dependencies

    #@commands = resolve @commands
  end

  def resolve commands
    commands.each do |command|
      command.dependencies.each do |dependency|
        commands - resolve(
          pp commands.select {|command| command.capability == dependency}
        )
      end
    end
  end
end
