class Node
  include BaseCapabilities
  attr_reader :name
  attr_accessor :capability_cache
  @@capabilities = []

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

  def self.load_capabilities
    Dir['../config/capabilities/*.rb'].each do |path|
      cache = private_methods
      load path
      capability_names = (private_methods - cache)
      capability_names.each do |capability_name|
        @@capabilities << capability_name.to_sym
      end
      log warning: "no cap in '#{path}'" unless capability_names.any?
    end
    log "#{@@capabilities.count} caps loaded from #{Dir['../config/capabilities/*.rb'].length} files"
  end

  def define_metaclasses cap
    # move method
    define_singleton_method(
      "__#{cap}".to_sym,
      &send(:method, cap)
    )
    # define replacewment method
    define_singleton_method cap do |*params|
      @jobs << Job.new(self, cap, params)
    end
    # define '?'-suffix version
    define_singleton_method "#{cap}?" do |param=nil|
      jobs = @jobs.find_all{|job| job.capability == cap}
      unless param
        # return ordered prarams
        params = jobs.collect{|job| job.ordered_params}.transpose
      else
        # return values of a named param
        params = jobs.find_all{ |job|
          job.named_params.include? param
        }.collect{ |job|
          job.named_params
        }.collect{ |named_params|
          named_params[param]
        }
      end
      # return nil instead of empty array (sure?)
      nil unless params.any?
    end
  end
end
