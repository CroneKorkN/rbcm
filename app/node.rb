class Node
  attr_reader :name
  @@capabilities = []

  def initialize name
    @name = name
    @cache_path = "#{File.dirname(__FILE__)}/cache/#{@name}"
    @collections = [] # Procs from node files
    @jobs = {} # saves all parameters passed to caps
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
    end
    # @files, @manipulations and @commands
    @jobs.each do |cap, joblist|
      joblist.each do |params|
        send "__#{cap}", *params
      end
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

  def options cap, param=nil
    return @jobs[cap].any? unless param
    all = []
    @jobs[cap].each do |job|
      all << job[0][param].flatten.uniq
    end
    all
  end

  def needs capability, or: nil

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
      @jobs[cap] = []
      define_singleton_method(
        "__#{cap}".to_sym,
        &send(:method, cap)
      )
      define_singleton_method cap do |*params|
        @jobs[__method__] << params
      end
    end
  end
end
