class Node
  def initialize name
    @name = name
    @cache_path = "#{File.dirname(__FILE__)}/cache/#{@name}"
    @jobs = [] # Procs from node files
    @config = {}
    @files = {} # path: "content"
    @manipulations = [] # array of commands for manipulating files
    @commands = [] # strings, run as root

    pp self.methods.sort
  end

  attr_reader :name

  def add_job job
    @jobs << job
  end

  def apply
    # job are executed, populating @files, @manipulations and @commands
    @jobs.each do |job|
      instance_exec &job
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
      capability_name = (private_methods - cache).first
      define_singleton_method capability_name do |*args|
        @config[capability_name] ||= []
        @config[capability_name] << args
        pp args
        send "real_#{capability_name}", args
      end
      define_singleton_method "real_#{capability_name}", &method(capability_name)
    end
    p Node.methods
  end
end

# foo.instance_exec(params, &proc) you
