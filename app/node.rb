class Node
  def initialize name
    @name = name
    @jobs = [] # Procs from node files
    @files = {} # path: "content"
    @manipulations = [] # array of commands for manipulating files
    @commands = [] # strings, run as root
  end

  def add_job job
    @jobs << job
  end

  def apply
    instance_eval &@jobs[0]
    #@jobs.each do |job|
      #instance_exec &job
    #end
    #@commands.collect {log(self)} # {`#{self}`}
    #with File.dirname "#{__FILE__}/../cache/#{@name}/#{path}/" do
    #  write content
    #end
  end

  def file(
      path,
      exists: nil,
      includes_line: nil,
      mode: nil,
      content: nil
    )
    @files[path] = content if content or exists
    @commands << "chmod #{mode}" if mode
    @commands << "
      if ! grep -q #{includes_line} #{path}; then
        echo #{includes_line} >> #{path}
      fi
      " if includes_line
  end

  def run command
    @commands << command
  end

  def foo
    p "test: #{self}"
  end

  def self.load_capabilities
    Dir['../config/capabilities/*.rb'].each do |path|
      cache = private_methods
      load path
      capability_name = (private_methods - cache).first
      define_singleton_method capability_name, &method(capability_name)
    end
  end
end

# foo.instance_exec(params, &proc) you
