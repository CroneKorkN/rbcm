# runs a definition and catches jobs
# accepts definition-Proc and provides definition-Proc and job list

class Sandbox
  attr_reader :content, :jobs

  def initialize node
    @node = node
    @dependency_cache = []
    @chain_cache = []
    @trigger_cache =[]
    @check_cache = []
  end

  def evaluate definitions
    [definitions].flatten.each do |definition|
      instance_eval &definition
    end
  end

  def trigger name, &block
    @trigger_cache << name
    @chain_cache << "trigger:#{name}"
    instance_eval &block
    @trigger_cache.pop
    @chain_cache.pop
  end

  def group name, &block
    if block_given?
      @node.rbcm.group_additions[name] ||= []
      @node.rbcm.group_additions[name] << block
    else
      @node.memberships << name
      @chain_cache << "group:#{name}"
      instance_eval &Group[name]
      @chain_cache.pop
    end
  end

  def dont *params
    puts "dont #{params}"
  end

  def needs *capabilities
    @dependency_cache += [capabilities].flatten
  end

  def check command, &block
    @check_cache << command
    instance_eval &block
    @check_cache.pop
  end

  def run command, check: nil
    @node.commands << Command.new(
      node: @node,
      line: command,
      check: check,
      chain: [@chain_cache].flatten(1).dup,
      params: @params_cache.dup,
      dependencies: @dependency_cache.dup,
      triggered_by: @trigger_cache.dup
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
      after: nil,
      mode: nil,
      content: nil
    )
    # @files[path] = content if content or exists
    run "echo #{Shellwords.escape(content)} > #{path}" if content
    manipulate "chmod #{mode} #{path}" if mode
    manipulate %^
      if  grep -q #{includes_line} #{path}; then
        echo #{includes_line} >> #{path}
      fi
    ^ if includes_line
  end

  # handle getter method calls
  def method_missing name, *params, &block
    log "method #{name} missing"
    capability_name = name[0..-2].to_sym
    if not @@capabilities.include? capability_name
      super
    elsif name =~ /\!$/
      return # dont call cap!
    elsif name =~ /\?$/
      __search capability_name, params
    end
  end

  def __search capability_name, params
    jobs = @node.jobs.find_all{|job| job.capability == capability_name}
    if params.empty?
      # return ordered prarams
      jobs.each.ordered_params
    elsif params.first.class == Symbol
      # return values of a named param
      jobs.find_all{ |job|
        job.named_params.include? params.first if job.named_params
      }.collect{ |job|
        job.named_params
      }.collect{ |named_params|
        named_params[params.first]
      }
    elsif params.first.class == Hash
      if params.first[:nodes] == :all
        jobs = @node.rbcm.nodes.values.each.jobs.flatten(1).find_all{|job| job.capability == capability_name}
      end
      if params.first.keys.first == :with
        # return values of a named param
        jobs.find_all{ |job|
          job.named_params.keys.include? params.first.values.first if job.named_params?
        }.each.named_params
      end
    end
  end

  def self.import_capabilities capabilities_path
    instance_methods_cache = instance_methods(false)
    Dir["#{capabilities_path}/*.rb"].each {|path|
      eval File.read(path)
    }
    @@capabilities = instance_methods(false).grep(
      /[^\!]$/
    ).-(
      instance_methods_cache
    ).+(
      [:file, :manipulate]
    )
    @@capabilities.each do |capability_name|
      # copy method
      define_method(
        "__#{capability_name}".to_sym,
        instance_method(capability_name)
      )
      # define wrapper method
      define_method(capability_name.to_sym) do |*params|
        @node.jobs << Job.new(capability_name, params)
        @params_cache = params || nil
        @chain_cache << capability_name
        r = send "__#{__method__}", *params
        @chain_cache.pop
        @dependency_cache = [:file]
        return r
      end
      next unless instance_methods(false).include? "#{capability_name}!".to_sym
      # copy method
      define_method(
        "__#{capability_name}!".to_sym,
        instance_method("#{capability_name}!")
      )
      # define wrapper method
      define_method("#{capability_name}!".to_sym) do |*params|
        @node.jobs << Job.new(capability_name, params)
        @params_cache = params || nil
        @chain_cache << "#{capability_name}!"
        r = send "__#{__method__}", *params
        @chain_cache.pop
        @dependency_cache = [:file]
        return r
      end
    end
  end
end
