class Node
  attr_reader :name
  @@capabilities = []

  def initialize name
    @name = name
    @cache_path = "#{File.dirname(__FILE__)}/cache/#{@name}"
    @collections = [] # Procs from node files
    @dependency_cache = [] # save the dependencies through each collection
    @jobs = [] # saves all parameters passed to caps
    @files = {} # path: "content"
    @manipulations = [] # array of commands for manipulating files
    @commands = [] # strings, run as root
    abstractize_capabilities
  end

  def add_collection collection
    @collections << collection
  end

  def render
    # collection are executed, collecting @jobs
    @collections.each do |collection|
      instance_exec &collection
      @dependency_cache = []
    end
    # @files, @manipulations and @commands
    @jobs.each do |job|
      job.run
    end
    # files are generated
    @files.each do |path, content|
      with @cache_path+path do
        FileUtils.mkdir_p File.dirname(self) unless File.directory? File.dirname(self)
        File.write self, content
      end
    end
    # commands are placed in file
    File.write "#{@cache_path}.sh", (@manipulations+@commands).join("\n")
    # copy files to server scp
    'scp'
  end

  private

  def needs capability, or: nil
    @dependency_cache = capability
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

  def run command
    @commands << command
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

  def abstractize_capabilities
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
          jobs.any?
        else
          jobs.find_all{ |job|
            job.params.include? param
          }.collect{ |job|
            job.params
          }.find_all{ |param|
            param.class = Hash
          }.collect
        end
      end
    end
  end
end
