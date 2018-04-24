class Node
  attr_reader :jobs, :definitions, :files, :name, :remote
  attr_accessor :commands, :memberships, :triggered

  def initialize name
    @name = name
    @definitions = []
    @sandbox = Sandbox.new self
    @files = FileList.new self
    @remote = Remote.new self
    @commands = []
    @memberships = []
    @jobs = []
    @triggered = []
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
end
