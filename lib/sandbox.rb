# runs a definition and catches jobs
# accepts definition-Proc and provides definition-Proc and job list

class Sandbox
  attr_reader :content, :jobs

  def initialize node
    @node = node
    @name = node.name
    @dependency_cache = []
    @chain_cache = [node.name]
    @trigger_cache = []
    @triggered_by_cache = []
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

  def triggered_by name, &block
    @triggered_by_cache << name
    @chain_cache << "triggered_by:#{name}"
    instance_eval &block
    @triggered_by_cache.pop
    @chain_cache.pop
  end

  def group name, &block
    if block_given?
      # send to group
      @node.rbcm.group_additions[name] << block
    else
      # include group
      raise "undefined group #{name}" unless @node.rbcm.groups[name]
      @node.memberships << name
      @chain_cache << "group:#{name}"
      @node.rbcm.groups[name].each do |definition|
        instance_eval &definition
      end
      @chain_cache.pop
    end
  end

  def dont *params
    puts "dont #{params}"
  end

  def needs *capabilities
    @dependency_cache += [capabilities].flatten(1)
  end

  def check action, &block
    @check_cache << action
    instance_eval &block
    @check_cache.pop
  end

  def run action, check: nil, trigger: nil, triggered_by: nil
    @node.actions << Command.new(
      node: @node,
      line: action,
      check: check,
      chain: [@chain_cache].flatten(1).dup,
      params: @params_cache.dup,
      dependencies: @dependency_cache.dup,
      trigger: [@trigger_cache.dup, trigger].flatten(1),
      triggered_by: [triggered_by, @triggered_by_cache.dup].flatten(1)
    )
  end

  def file path, trigger: nil, **named
     raise "RBCM: invalid file paramteres '#{named}'" if (
       named.keys - [:exists, :includes_line, :after, :mode, :content, :template, :context]
     ).any?
     @node.actions << FileAction.new(
       node: @node,
       path: path,
       params: Params.new([path], named),
       chain: [@chain_cache.dup].flatten(1),
       trigger: [@trigger_cache.dup, trigger].flatten(1),
       triggered_by: @triggered_by_cache.dup
     )
  end

  # handle getter method calls
  def method_missing name, *named, **ordered, &block
    log "method #{name} missing on #{@name}"
    capability_name = name[0..-2].to_sym
    params = Params.new named, ordered
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
      jobs.collect{|job| job.params.ordered}
    elsif params.first.class == Symbol
      # return values of a named param
      jobs.find_all{ |job|
        job.params.named.include? params.first if job.params.named.any?
      }.collect{ |job|
        job.params.named
      }.collect{ |named_params|
        named_params[params.first]
      }
    elsif params.named.any?
      if params[:nodes] == :all
        jobs = @node.rbcm.nodes.values.each.jobs.flatten(1).find_all{|job| job.capability == capability_name}
      end
      if params[:with]
        # return values of a named param
        jobs.find_all{ |job|
          job.params.named.keys.include? params[:with] if job.params.named.any?
        }.collect{ |job|
          job.params.named
        }
      end
    end
  end

  def self.import_capabilities capabilities_path
    instance_methods_cache = instance_methods(false)
    Dir["#{capabilities_path}/**/*.rb"].each {|path|
      eval File.read(path)
    }
    @@capabilities = instance_methods(false).grep(
      /[^\!]$/
    ).-(
      instance_methods_cache
    ).+(
      [:file]
    )
    log "CAPABILITIES #{@@capabilities}"
    @@capabilities.each do |capability_name|
      # copy method
      define_method(
        "__#{capability_name}".to_sym,
        instance_method(capability_name)
      )
      # define wrapper method
      define_method(capability_name.to_sym) do |*ordered, **named|
        params = Params.new ordered, named
        @trigger_cache << params[:trigger] if params[:trigger]
        @triggered_by_cache << params[:triggered_by] if params[:triggered_by]
        @node.jobs << Job.new(capability_name, params)
        @node.triggered << capability_name 
        @params_cache = params
        @chain_cache << capability_name
        clean_params = params.dup; clean_params.named.delete(:trigger); clean_params.named.delete(:triggered_by)
        r = send "__#{__method__}", *clean_params.sendable
        @chain_cache.pop
        @trigger_cache.pop if params[:trigger]
        @triggered_by_cache.pop if params[:triggered_by]
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
        @params_cache = params
        @chain_cache << "#{__method__}"
        r = send "__#{__method__}", *params
        @chain_cache.pop
        @dependency_cache = [:file]
        return r
      end
    end
  end
end
