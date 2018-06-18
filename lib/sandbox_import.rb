module Sandbox::Import
  def self.included klass
    klass.extend Sandbox::Import::ClassMethods
  end

  def initialize project_file_path
    @path = project_file_path
    @definitions = []
    file = File.read project_file_path
    @capabilities = Capabilities.dup.instance_eval file
    method_names_cache = methods(false)
    instance_eval file

    (methods(false) - method_names_cache).each do |capability_name|
      @capabilities.append Capability.new(
        name:    capability_name.to_sym,
        content: method(capability_name).to_proc
      )
    end
    binding.pry
  end

  attr_reader :capabilities, :definitions, :path

  private

  def group name=nil
    @definitions.append Definition.new(
      type:    :group,
      name:    name,
      content: Proc.new
    )
  end

  def node names=nil
    [names].flatten(1).each do |name|
      @definitions.append Definition.new(
        type:    name.class == Regexp ? :pattern : :node,
        name:    name,
        content: Proc.new
      )
    end
  end
end

module Sandbox::Import::ClassMethods
  def capabilities
    @@capabilities
  end

  def wrap_capability name
    @@capabilities ||= []
    @@capabilities << name unless name[-1] == "!"
    # define capability method
    define_method :"__#{capability.name}", &method(name)
    # define wrapper method
    define_method(capability.name.to_sym) do |*ordered, **named|
      if capability.type == :regular
        params = Params.new ordered, named
        @node.jobs.append Job.new @node, capability.name, params
        @node.triggered.append capability.name
        __cache trigger: params[:trigger],
              triggered_by: params[:triggered_by],
              chain: capability.name do
          send "__#{__method__}", *params.delete(:trigger, :triggered_by).sendable
        end
      else # capability.type == :final
        __cache chain: __method__ do
          send "__#{__method__}"
        end
      end
      @dependency_cache = [:file]
    end
  end
end
