# runs a definition and catches jobs
# accepts definition-Proc and provides definition-Proc and job list

class Sandbox
  def self.eval code
    super code
  end

  def self.capabilities
    @@capabilities
  end

  def self.capabilities= capabilities
    @@capabilities = capabilities
  end
end

class Sandbox
  attr_reader :content, :jobs, :commands, :memberships

  def initialize node
    @node = node
    @jobs = []
    @commands = []
    @files = {}
    @dependency_cache = []
    @memberships = []
    @chain = []
  end

  def evaluate definitions
    [definitions].flatten.each do |definition|
      instance_eval &definition
    end
  end

  def group name
    @memberships << name
    @chain << "group:#{name}"
    instance_eval &Group[name]
    @chain.pop
  end

  def dont *params
    p "dont #{params}"
  end

  def needs *capabilities
    @dependency_cache += [capabilities].flatten
  end

  def run command, check: nil
    p @chain
    p command
    @commands << Command.new(
      node: @node,
      line: command,
      check: check,
      chain: [@chain].flatten(1).dup,
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
    puts "method #{name} missing"
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
      if params.first.keys.first == :with
        # return values of a named param
        j = jobs.find_all{ |job|
          job.named_params.keys.include? params.first.values.first if job.named_params?
        }.each.named_params
        p j
        j
      end
    end
  end
end