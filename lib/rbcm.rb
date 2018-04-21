require "quickeach"
PWD = ARGV[0]
APPDIR = File.expand_path File.dirname(__FILE__)
require "fileutils"
[ :lib, :definition_file, :node, :group, :command_list,
  :command, :definition, :job, :remote
].each{|requirement| require "#{APPDIR}/#{requirement}.rb"}

class RBCM
  attr_reader :nodes, :groups, :project_path

  def initialize project_path
    @patterns = {}
    @nodes = {}
    import_capabilities "#{project_path}capabilities"
    @capabilities = Definition.capabilities
    import_definitions "#{project_path}definitions"
    @groups = Group.all
  end

  def parse
    nodes.each_value{|node| node.parse}
  end

  def approve
    commands.each.approve
  end

  def apply
    commands.each.apply
  end

  private

  def import_capabilities capabilities_path
    remember = Definition.instance_methods(false)
    Dir["#{PWD}/capabilities/*.rb"].each {|path|
      Definition.eval File.read(path)
    }
    Definition.capabilities = Definition.instance_methods(false).grep(
      /[^\!]$/
    ).-(
      remember
    ).+(
      [:file, :manipulate]
    )

    Definition.capabilities.each do |capability_name|
      # copy method
      Definition.define_method(
        "__#{capability_name}".to_sym,
        Definition.instance_method(capability_name)
      )
      # define wrapper method
      Definition.define_method(capability_name.to_sym) do |*params|
        @jobs << Job.new(capability_name, params)
        @capability_cache = capability_name
        @params_cache = params || nil
        r = send "__#{__method__}", *params
        @dependency_cache = [:file]
        return r
      end

      # define getter method
      Definition.define_method "#{capability_name}?".to_sym do |param=nil|
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

  private

  def commands
    @commands ||= nodes.each.commands
  end
end
