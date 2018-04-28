class Node
  attr_reader :jobs, :definitions, :files, :name, :remote, :rbcm, :sandbox
  attr_accessor :commands, :memberships, :triggered

  def initialize rbcm, name
    @rbcm = rbcm
    @name = name
    @definitions = []
    @sandbox = Sandbox.new self
    @files = FileSystem.new self
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
    @sandbox.evaluate definitions
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

  def additions
    @rbcm.group_additions.select{|group, additions| memberships.include? group}.flatten(1)
  end
end
