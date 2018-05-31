# runs a definition and catches jobs
# accepts definition-Proc and provides definition-Proc and job list

class Sandbox
  attr_reader :content, :jobs

  def initialize node
    @node = node
    @name = node.name
    @dependency_cache = []
    @cache = {chain: [@node.name], trigger: [], triggered_by: [], check: [], source: []}
  end

  def evaluate definitions
    [definitions].flatten.each do |definition|
      instance_eval &definition
    end
  end

  def trigger name, &block
    __cache trigger: name, chain: "trigger:#{name}" do
      instance_eval &block
    end
  end

  def triggered_by name, &block
    __cache triggered_by: name, chain: "triggered_by:#{name}" do
      instance_eval &block
    end
  end

  def group name, &block
    if block_given? # expand group
      @node.rbcm.group_additions[name] << block
    else # include group
      raise "undefined group #{name}" unless @node.rbcm.groups[name]
      @node.memberships << name
      __cache chain: "group:#{name}" do
        @node.rbcm.groups[name].each do |definition|
          instance_eval &definition
        end
      end
    end
  end

  def dont *params
    puts "dont #{params}"
  end

  def needs *capabilities
    @dependency_cache += [capabilities].flatten(1)
  end

  def check action, &block
    __cache check: action do
      instance_eval &block
    end
  end

  def run action, check: nil, trigger: nil, triggered_by: nil
    @node.actions << Command.new(
      line: action,
      check: check,
      chain: @cache[:chain].dup.flatten(1),
      dependencies: @dependency_cache.dup,
      trigger: [@cache[:trigger].dup, trigger].flatten(1),
      triggered_by: [triggered_by, @cache[:triggered_by].dup].flatten(1),
      job: @node.jobs.last,
      source: @cache[:source].flatten
    )
  end

  def file path, trigger: nil, **named
     raise "RBCM: invalid file paramteres '#{named}'" if (
       named.keys - [:exists, :includes_line, :after, :mode, :content, :template, :context]
     ).any?
     @node.actions << FileAction.new(
       path: path,
       params: Params.new([path], named),
       chain: [@cache[:chain].dup].flatten(1),
       trigger: [@cache[:trigger].dup, trigger].flatten(1),
       triggered_by: @cache[:triggered_by].dup,
       job: @node.jobs.last,
       source: @cache[:source].flatten
     )
  end

  # handle getter method calls
  def method_missing name, *named, **ordered, &block
    #log "method #{name} missing on #{@name}"
    capability_name = name[0..-2].to_sym
    params = Params.new named, ordered
    if not @@capabilities.include? capability_name
      super
    elsif name =~ /\!$/
      return # never call cap! diectly
    elsif name =~ /\?$/
      __search capability_name, params, &block
    end
  end

  def __search capability_name, params, &block
    if params[:nodes] == :all
      jobs = @node.rbcm.jobs
    else
      jobs = @node.jobs
    end
    jobs = jobs.select{|job| job.capability == capability_name}
    if params.delete(:nodes).empty?
      # return ordered prarams
      r = jobs.collect{|job| job.params}
    elsif params[0].class == Symbol
      # return values of a named param
      r = jobs.find_all{ |job|
        job.params.named.include? params.first if job.params.named.any?
      }.collect{ |job|
        job.params.named
      }.collect{ |named_params|
        named_params[params.first]
      }
    elsif params.named.any?
      if params[:with]
        # return values of a named param
        r = jobs.find_all{ |job|
          job.params.named.keys.include? params[:with] and job.params.named.any?
        }.collect{ |job|
          params = job.params
          params[:source] = job.node.name
          params
        }
      end
    end
    return r.collect &block if block_given? # no-each-syntax
    return r
  end

  def self.import_capabilities capabilities_path
    instance_methods_cache = instance_methods(false)
    Dir["#{capabilities_path}/**/*.rb"].each {|path|
      eval File.read(path)
    }
    @@capabilities = instance_methods(false).grep(/[^\!]$/) -
                     instance_methods_cache +
                     [:file, :run]
    @@capabilities.each do |capability_name|
      # copy method
      define_method(
        :"__#{capability_name}",
        instance_method(capability_name)
      )
      # define wrapper method
      define_method(capability_name.to_sym) do |*ordered, **named|
        params = Params.new ordered, named
        @node.jobs << Job.new(@node, capability_name, params)
        @node.triggered << capability_name
        __cache trigger: params[:trigger],
              triggered_by: params[:triggered_by],
              chain: capability_name do
          send "__#{__method__}", *params.delete(:trigger, :triggered_by).sendable
        end
        @dependency_cache = [:file]
      end
      next unless instance_methods(false).include? :"#{capability_name}!"
      # copy method
      define_method(
        :"__#{capability_name}!",
        instance_method(:"#{capability_name}!")
      )
      # define wrapper method
      define_method(:"#{capability_name}!") do
        __cache chain: __method__ do
          send "__#{__method__}"
        end
        @dependency_cache = [:file]
      end
    end
  end

  def __cache trigger: nil, triggered_by: nil, params: nil, check: nil,
      chain: [], source: nil, reset: nil
    @cache[:source].append []             if chain
    @cache[:source].last  << source       if source
    @cache[:chain]        << chain        if chain
    @cache[:trigger]      << trigger      if trigger
    @cache[:triggered_by] << triggered_by if triggered_by
    @cache[:check]        << check        if check
    yield if block_given?
    @cache[:source].pop                   if chain
    @cache[:chain].pop                    if chain
    @cache[:trigger].pop                  if trigger
    @cache[:triggered_by].pop             if triggered_by
    @cache[:check].pop                    if check
    @cache[reset]         = []            if reset
  end

  def self.capabilities
    @@capabilities
  end
end
