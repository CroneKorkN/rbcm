class Node
  def initialize name
    @name = name
    @jobs = [] # lambdas from node files
    @files = {} # path: "content"
    @manipulations = [] # array of commands for manipulating files
    @commands = [] # strings, run as root
  end

  def add_job job
    @jobs.append! job
  end

  def apply node
    @jobs.collect {call}
    @commands.collect {log(self)} # {`#{self}`}
    with File.dirname "#{__FILE__}/../cache/#{@name}/#{path}/" do
      write content
    end
  end

  def file  path,
            exists: nil,
            includes_line: nil,
            mode: nil,
            content: nil
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

  private

  def self.load_capabilities
    Dir['../config/capabilities/*.rb'].each do |path|
      methods_cached = methods
      load path
      function_name = (methods - methods_cached).to_s
      p path
      p methods_cached.sort
      p methods.sort
      puts function_name.to_sym
      method = lambda(&method(function_name.to_sym))
      self.define_method function_name, &method
    end
  end
end
