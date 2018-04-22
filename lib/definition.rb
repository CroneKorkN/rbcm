# runs a definition and catches jobs
# accepts definition-Proc and provides definition-Proc and job list

class Definition
  def self.eval code
    super code
  end

  def self.capabilities
    @@capabilities
  end

  def self.capabilities= capabilities
    @@capabilities = capabilities
  end

  attr_reader :content, :jobs, :commands, :memberships
  attr_accessor :node

  def initialize node=nil, &content
    @node = node
    @content = content
    @jobs = []
    @commands = []
    @dependency_cache = []
    @memberships = []
  end

  def parse
    instance_eval &@content
  end

  def group name
    @memberships << name
    instance_eval &Group[name].content
  end

  def dont *args
    p "dont #{args}"
  end

  # calling 'needs' adds dependency to each command from now in this job
  def needs *capabilities
    #log error: "dont call 'needs' in node" unless @capability
    #log error: "dependency '#{capability}' from '#{@capability_cache}' doesn't exist" unless @@capabilities.include? capability
    @dependency_cache += [capabilities].flatten
  end

  def run command, check: nil
    @commands << Command.new(
      node: @node,
      line: command,
      capability: @capability_cache,
      params: @params_cache,
      dependencies: @dependency_cache,
      check: check
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

  # handle getter method calls
  def method_missing name, *args, &block
    capability_name = name[0..-2].to_sym
    p name
    p @@capabilities
    if not @@capabilities.include? capability_name
      p 99999
      super
    elsif name =~ /\!$/
      return
    elsif name =~ /\!$/
      # search
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

#p Definition.instance_methods.sort
