module Capabilities
  # calling 'needs' adds dependency to each command from now in this job
  def needs capability
    log error: "dont call 'needs' in node" unless @capability_cache
    #log error: "dependency '#{capability}' from '#{@capability_cache}' doesn't exist" unless @@capabilities.include? capability
    @dependency_cache << capability
  end

  def run command
    @commands << Command.new(command, @capability_cache, @dependency_cache)
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

  extend self # make methods accessile: https://stackoverflow.com/questions/2660646/send-instance-method-to-module

  c = private_methods
  Dir['../config/capabilities/*.rb'].each {|path| load path}
  (
    (private_methods - c) + [:file, :manipulate]
  ).each do |cap|
    p 11111
    # move method
    define_singleton_method(
      "__#{cap}".to_sym,
      Proc.new(&send(:method, cap))
    )
    # define replacewment method
    define_singleton_method cap do |*params|
      @jobs << Job.new(self, cap, params)
    end
    # define '?'-suffix version
    define_singleton_method "#{cap}?" do |param=nil|
      jobs = @jobs.find_all{|job| job.capability == cap}
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

  p methods
end
