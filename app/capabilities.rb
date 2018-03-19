class Capabilities
  # include user-defined capabilities
  Dir['../config/capabilities/*.rb'].each {|path| eval File.read path}
  # define '?'-suffix version to read configuration
  @@capabilities = instance_methods(false)

  def define_getters
    @@capabilities.each do |capability_name|
      self.define_singleton_method "#{capability_name}?".to_sym do |param=nil|
        "XXXXXXXXXXXXXXXXXXX"
      end
    end
  end

  # calling 'needs' adds dependency to each command from now in this job
  def needs *capabilities
    log error: "dont call 'needs' in node" unless @capability
    #log error: "dependency '#{capability}' from '#{@capability_cache}' doesn't exist" unless @@capabilities.include? capability
    @dependency_cache += [capabilities].flatten
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
end

#Capabilities.define_getters
