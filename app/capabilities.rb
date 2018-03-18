class Capabilities
  Dir['../config/capabilities/*.rb'].each {|path| eval File.read path}

  def self.define_getter_methods
    instance_methods(false).each do |capability_name|
      define_method "#{capability_name}?".to_sym do |param=nil|

      end
    end
  end

  # calling 'needs' adds dependency to each command from now in this job
  def needs capability
    log error: "dont call 'needs' in node" unless @capability
    #log error: "dependency '#{capability}' from '#{@capability_cache}' doesn't exist" unless @@capabilities.include? capability
    @dependency_cache << capability
  end

  def run command
    @commands << Command.new(command, @capability, @dependency_cache)
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

  define_getter_methods
end
