class Node
  @@capabilities = []
  attr_reader :name
  attr_accessor :capability_cache
  include Capabilities

  def initialize name
    @name = name
    @cache_path = "#{File.dirname(__FILE__)}/cache/#{@name}"
    @collections = [] # Procs from node files
    @capability_cache = nil # save the capability name of the job executed now
    @dependency_cache = [] # save the dependencies through each collection
    @jobs = [] # saves all parameters passed to caps
    @commands = CommandList.new
    @@capabilities.each {|cap| define_metaclasses cap}
    define_metaclasses :file
    define_metaclasses :manipulate
  end

  def add_collection collection
    @collections << collection
  end

  def render
    # collection are executed, collecting @jobs
    @collections.each do |collection|
      instance_exec &collection
    end
    @jobs.each do |job|
      job.run
      @dependency_cache = []
    end
  end

  private

  # calling 'needs' adds dependency to each command from now in this job
  def needs capability
    log error: "dont call 'needs' in node" unless @capability_cache
    log error: "dependency '#{capability}' from '#{@capability_cache}' doesn't exist" unless @@capabilities.include? capability
    @dependency_cache << capability
  end
end
