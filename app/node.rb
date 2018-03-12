class Node
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
    @files = {} # path: "content"
    @manipulations = [] # array of commands for manipulating files
    @commands = CommandList.new # strings, run as root
    abstractize_capabilities!
  end

  def add_collection collection
    @collections << collection
  end

  def render
    # collection are executed, collecting @jobs
    @collections.each do |collection|
      instance_exec &collection
    end
    # @files, @manipulations and @commands
    @jobs.each do |job|
      job.run
      @dependency_cache = []
    end
    # files are generated
    @files.each do |path, content|
      with @cache_path+path do
        FileUtils.mkdir_p File.dirname(self) unless File.directory? File.dirname(self)
        File.write self, content
      end
    end
    # commands are placed in file
    File.write "#{@cache_path}.sh", @commands.render
    # copy files to server scp
    'scp'
  end

  private

  def needs capability
    @dependency_cache << capability
  end

  def file(
      path,
      exists: nil,
      includes_line: nil,
      mode: nil,
      content: nil
    )
    @files[path] = content if content or exists
    @manipulations << "chmod #{mode}" if mode
    @manipulations << %^
      if  grep -q #{includes_line} #{path}; then
        echo #{includes_line} >> #{path}
      fi
    ^ if includes_line
  end

  def run line
    @commands << Command.new(line, @capability_cache, @dependency_cache)
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

  def abstractize_capabilities!
    @@capabilities.each do |cap|
      # move method
      define_singleton_method(
        "__#{cap}".to_sym,
        &send(:method, cap)
      )
      # define replacewment method
      define_singleton_method cap do |*params|
        @jobs << Job.new(self, cap, params, @dependency_cache)
      end
      # define '?'-suffix version
      define_singleton_method "#{cap}?" do |param=nil|
        jobs = @jobs.find_all{|job| job.capability == cap}
        unless param
          # return all ordered params passed
          params = jobs.collect{|job| job.ordered_params}.transpose
        else
          params = jobs.find_all{ |job|
            job.named_params.include? param
          }.collect{ |job|
            job.named_params
          }.collect{ |named_params|
            named_params[param]
          }
        end
        nil unless params.any?
      end
    end
  end
end
