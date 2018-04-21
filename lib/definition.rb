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
end

#p Definition.instance_methods.sort
