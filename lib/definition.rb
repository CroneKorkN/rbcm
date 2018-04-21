# runs a definition and catches jobs
# accepts definition-Proc and provides definition-Proc and job list

class Definition
  attr_reader :content

  def initialize content
    @content = content
    @jobs = []
    @commands = []
    @dependency_cache = []
  end

  def parse
    instance_eval &@content
  end

  def group name
    p Group[name]
    instance_eval &Group[name].content
  end

  def dont *args
    p "dont #{args}"
  end

  # include user-defined capabilities
  unless defined? @@capabilities
    Dir["#{PWD}/capabilities/*.rb"].each {|path| eval File.read path}
    # define '?'-suffix version to read configuration
    @@capabilities = instance_methods(false) + [:file, :manipulate]
  end

  def self.capabilities
    @@capabilities
  end


  # calling 'needs' adds dependency to each command from now in this job
  def needs *capabilities
    #log error: "dont call 'needs' in node" unless @capability
    #log error: "dependency '#{capability}' from '#{@capability_cache}' doesn't exist" unless @@capabilities.include? capability
    @dependency_cache += [capabilities].flatten
  end

  def run command
    @commands << Command.new(
      line: command,
      capability: @capability_cache,
      params: @params_cache,
      dependencies: @dependency_cache
    )
  end

  def manipulate command
    needs :file
    run command
  end

  def file(
      path,
      exists: nil,
      includes_line: nil,
      mode: nil,
      content: nil
    )
    # @files[path] = content if content or exists
    run "echo '#{content}' > #{path}" if path
    manipulate "chmod #{mode} #{path}" if mode
    manipulate %^
      if  grep -q #{includes_line} #{path}; then
        echo #{includes_line} >> #{path}
      fi
    ^ if includes_line
  end

  @@capabilities.-([:group]).each do |capability_name|
    # copy method
    define_method(
      "__#{capability_name}".to_sym,
      instance_method(capability_name)
    )
    # define wrapper method
    define_method(capability_name.to_sym) do |*params|
      @jobs << Job.new(capability_name, params)
      @capability_cache = capability_name
      @params_cache = params || nil
      r = send "__#{__method__}", *params
      @dependency_cache = [:file]
      return r
    end

    ######
    self.define_method "#{capability_name}?".to_sym do |param=nil|
      jobs = @node.jobs.find_all{|job| job.capability == capability_name}
      unless param
        # return ordered prarams
        params = jobs.collect{|job| job.ordered_params}
      else
        # return values of a named param
        params = jobs.find_all{ |job|
          job.named_params.include? param if job.named_params
        }.collect{ |job|
          job.named_params
        }.collect{ |named_params|
          named_params[param]
        }
      end
      # return nil instead of empty array (sure?)
      params.any? ? params : nil
    end
  end
end
