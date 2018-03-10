class Node
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

  attr_reader :name

  def add_collection collection
    @collections << collection
  end

  def apply
    # collection are executed, populating @files, @manipulations and @commands
    @collections.each do |collection|
      instance_exec &collection
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
  end

  private

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
      capability_name = (private_methods - cache).first.to_sym
      @@capabilities << capability_name
    end
  end

  def abstractize_capabilities
    @@capabilities.each do |cap|
      @jobs[cap] = []
      define_singleton_method(
        "r_#{cap}".to_sym,
        &send(:method, cap)
      )
      define_singleton_method cap do |*params|
        @jobs[__method__] << params
        #send "r_#{__method__}", *params
      end
    end
  end
end

# foo.instance_exec(params, &proc) you
