class Capabilities
  Dir['../config/capabilities/*.rb'].each {|path| eval File.read path}

  instance_methods(false).each do |capability_name|
    define_method "#{capability_name}?".to_sym do |param=nil|
      jobs = @node.jobs.find_all{|job| job.capability == capability_name}
      unless param
        # return ordered prarams
        params = jobs.collect{|job| job.ordered_params}.transpose
      else
        # return values of a named param
        params = jobs.find_all{ |job|
          job.named_params.include? param
        }.collect{ |job|
          job.named_params
        }.collect{ |named_params|
          named_params[param]
        }
      end
      # return nil instead of empty array (sure?)
      nil unless params.any?
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
