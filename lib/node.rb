class Node
  attr_reader :jobs, :definitions, :files

  def initialize name
    @name = name
    @definitions = []
    @sandbox = Sandbox.new self
    @files = {}
  end

  def << definition
    @definitions << definition
  end

  def parse
    @sandbox.evaluate @definitions
    capabilities.each{|capability| @sandbox.send "#{capability}!"}
    #jobs.select{|job| job.capability == :file}.each do |job|
    #  path = job.params[0]
    #  @files[path] = File.new self, path unless @files[path]
    #  @files[path] << job.params
    #end
  end

  def check
    commands.each.check
  end

  def approve
    commands.each.approve
  end

  def jobs
    @sandbox.jobs.flatten(1)
  end

  def commands
    @sandbox.commands.flatten(1)
  end

  def capabilities
    jobs.each.capability.uniq
  end

  def remote
    @remote ||= Remote.new @name
  end

  def memberships
    @sandbox.memberships.flatten(1)
  end

  def affected_files
    @affected_files ||= commands.select{ |command|
      command.capability == :file
    }.collect{ |command|
      command.ordered_params.first
    }
  end
end
