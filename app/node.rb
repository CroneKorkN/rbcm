class Node
  def initialize name
    @name = name
    @jobs = [] # lambdas from node files
    @commands = [] # strings, run as root
    @files = {} # path: "content"
    @manipulations = [] # array of commands for manipulating files
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
      if ! grep -q #{includes_line} #{path}
      then echo #{includes_line} >> #{path}
    " if includes_line

  end

  def run command
    @commands << command
  end

  private

  def self.load_capabilities
    Dir['../config/capabilities/*.rb'].each do |path|
      load path
      function_name = File.basename path, '.rb'
      
      puts function_name
      function = lambda(&method(function_name.to_sym))
      puts function
      #self.define_method function_name, lambda(&method(function_name.to_sym))
    end
  end
end
