PWD = ARGV[0]
APPDIR = File.expand_path File.dirname(__FILE__)
require "net/ssh"
require "fileutils"
require 'shellwords'
[ :lib, :definition_file, :file_list, :execution, :node, :group, :command_list,
  :command, :job, :remote, :sandbox
].each{|requirement| require "#{APPDIR}/#{requirement}.rb"}

class RBCM
  attr_reader :nodes, :groups, :project_path

  def initialize project_path
    @patterns = {}
    @nodes = {}
    import_capabilities "#{project_path}/capabilities"
    @capabilities = Sandbox.capabilities
    import_definitions "#{project_path}/definitions"
    @groups = Group.all
  end

  def parse
    nodes.values.each.parse
  end

  def approve
    nodes.values.each.check
    nodes.values.each.approve
    #while commands.select{|c| c.obsolete == false and c.approved == nil}.any?
    #  commands.select{|c| c.obsolete == false and c.approved == nil}.first.approve
    #end
  end

  def apply
    commands.select{|c| c.approved}.each.apply
  end

  # private

  def import_capabilities capabilities_path
    instance_methods_cache = Sandbox.instance_methods(false)
    Dir["#{capabilities_path}/*.rb"].each {|path|
      Sandbox.eval File.read(path)
    }
    Sandbox.capabilities = Sandbox.instance_methods(false).grep(
      /[^\!]$/
    ).-(
      instance_methods_cache
    ).+(
      [:file, :manipulate]
    )
    Sandbox.capabilities.each do |capability_name|
      # copy method
      Sandbox.define_method(
        "__#{capability_name}".to_sym,
        Sandbox.instance_method(capability_name)
      )
      # define wrapper method
      Sandbox.define_method(capability_name.to_sym) do |*params|
        @node.jobs << Job.new(capability_name, params)
        @params_cache = params || nil
        @chain_cache << capability_name
        r = send "__#{__method__}", *params
        @chain_cache.pop
        @dependency_cache = [:file]
        return r
      end
      next unless Sandbox.instance_methods(false).include? "#{capability_name}!".to_sym
      # copy method
      Sandbox.define_method(
        "__#{capability_name}!".to_sym,
        Sandbox.instance_method("#{capability_name}!")
      )
      # define wrapper method
      Sandbox.define_method("#{capability_name}!".to_sym) do |*params|
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

  def import_definitions definitions_path
    Dir["#{definitions_path}/**/*.rb"].collect{ |definition_file_path|
      DefinitionFile.new definition_file_path
    }.each do |definition_file|
      definition_file.groups.each do |name, definition|
        Group[name] = definition
      end
      @patterns << definition_file.patterns
      definition_file.nodes.each do |name, definition|
        @nodes[name] = Node.new name unless @nodes[name]
        @nodes[name] << definition
      end
    end
    @patterns.each do |pattern, definition|
      @nodes.find(/#{pattern}/).each do |node|
        node << definition
      end
    end
  end

  def commands
    nodes.values.each.commands.flatten(1)
  end
end
