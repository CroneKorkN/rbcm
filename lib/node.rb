class Node
  attr_reader :jobs, :definitions, :files, :name
  attr_accessor :trigger, :commands, :memberships

  def initialize name
    @name = name
    @definitions = []
    @trigger = {}
    @sandbox = Sandbox.new self
    @files = {}
    @commands = []
    @memberships = []
    @jobs = []
  end

  def << definition
    @definitions << definition
  end

  def parse
    @sandbox.evaluate @definitions
    capabilities.each{|capability| @sandbox.send "#{capability}!"}
    # jobs -> files
    #jobs.select{|job| job.capability == :file}.each do |job|
    #  path = job.params[0]
    #  @files[path] ||= File.new self, path
    #  @files[path] << job.params
    #end
  end

  def check
    commands.each.check
  end

  def approve
    commands.each.approve
  end

  def capabilities
    jobs.each.capability.uniq
  end

  def remote
    @remote ||= Remote.new @name
  end

  def affected_files
    @affected_files ||= commands.select{ |command|
      command.capability == :file
    }.collect{ |command|
      command.ordered_params.first
    }
  end
end
