# runs a definition and catches jobs
# accepts definition-Proc and provides definition-Proc and job list

class Node::Sandbox
  attr_reader :content, :jobs

  def initialize node
    @node = node
    @name = node.name
    @dependency_cache = []
    @cache = {
      chain: [@node.name], trigger: [], triggered_by: [], check: [],
      source: [], tag: []
    }
    # define in instance, otherwise method-binding will be wrong (to class)
    @@capabilities = @node.rbcm.project.capabilities.each.name
    @node.rbcm.project.capabilities.each do |capability|
      add_capability capability
    end
  end

  def evaluate definitions
    [definitions].flatten.each do |definition|
      __cache chain: definition.origin do
        instance_eval &definition.content
      end
    end
  end

  def tag name, &block
    __cache tag: name, chain: "tag:#{name}" do
      instance_eval &block
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
          instance_eval &definition.content
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

  def run action, check: nil, tags: nil, trigger: nil, triggered_by: nil
    @node.actions << Action::Command.new(
      line: action,
      check: check,
      chain: @cache[:chain].dup.flatten(1),
      dependencies: @dependency_cache.dup,
      tags: [tags] + @cache[:tag].dup,
      trigger: [@cache[:trigger].dup, trigger].flatten(1),
      triggered_by: [triggered_by, @cache[:triggered_by].dup].flatten(1),
      job: @node.jobs.last,
      source: @cache[:source].dup.flatten, # information from other nodes
      origin: @cache[:origin].dup # origin of the definition
    )
  end

  def file path, trigger: nil, **named
     raise "RBCM: invalid file paramteres '#{named}'" if (
       named.keys - [:exists, :includes_line, :after, :mode, :content,
         :template, :context, :tags]
     ).any?
     @node.actions << Action::File.new(
       path: path,
       params: Params.new([path], named),
       chain: [@cache[:chain].dup].flatten(1),
       tags: [named[:tags]] + @cache[:tag].dup,
       trigger: [@cache[:trigger].dup, trigger].flatten(1),
       triggered_by: @cache[:triggered_by].dup,
       job: @node.jobs.last,
       source: @cache[:source].dup.flatten, # information from other nodes
       origin: @cache[:origin].dup # origin of the definition
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
    if params[:nodes] == :all # scope
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

  def __cache trigger: nil, triggered_by: nil, params: nil, check: nil,
      chain: [], source: nil, reset: nil, tag: nil, origin: nil
    @cache[:source].append []             if chain
    @cache[:source].last  << source       if source
    @cache[:chain]        << chain        if chain
    @cache[:tag]          << tag          if tag
    @cache[:trigger]      << trigger      if trigger
    @cache[:triggered_by] << triggered_by if triggered_by
    @cache[:check]        << check        if check
    @cache[:origin]       =  origin       if origin
    yield if block_given?
    @cache[:source].pop                   if chain
    @cache[:chain].pop                    if chain
    @cache[:tag].pop                      if tag
    @cache[:trigger].pop                  if trigger
    @cache[:triggered_by].pop             if triggered_by
    @cache[:check].pop                    if check
    @cache[reset]         =  []           if reset
    @cache[:origin]       =  nil          if origin
  end

  def add_capability capability
    @@capabilities << capability.name unless capability.name[-1] == "!"
    # define capability method
    define_singleton_method :"__#{capability.name}", &capability.content.bind(self)
    # define wrapper method
    if capability.type == :regular
      define_singleton_method capability.name do |*ordered, **named|
        params = Params.new ordered, named
        @node.jobs.append Node::Job.new @node, capability.name, params
        @node.triggered.append capability.name
        __cache trigger: params[:trigger],
              triggered_by: params[:triggered_by],
              chain: capability.name do
          send "__#{__method__}", *params.delete(:trigger, :triggered_by).sendable
        end
        @dependency_cache = [:file]
      end
    else # capability.type == :final
      define_singleton_method capability.name do
        __cache chain: __method__ do
          send "__#{__method__}"
        end
        @dependency_cache = [:file]
      end
    end
  end

  def self.capabilities
    @@capabilities.uniq
  end
end
