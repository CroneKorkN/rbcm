class Node
  attr_reader :jobs, :definitions, :files, :name, :remote, :rbcm, :sandbox
  attr_accessor :actions, :memberships, :triggered

  def initialize rbcm, name
    @rbcm = rbcm
    @name = name
    @definitions = []
    @sandbox = Sandbox.new self
    @remote = Remote.new self
    @files = FileSystem.new self, mirror: @remote.files
    @actions = ActionList.new
    @memberships = []
    @jobs = []
    @blocked_jobs = []
    @triggered = [:file]
  end

  def << definition
    @definitions << definition
  end

  def parse
    @sandbox.evaluate definitions
  end

  def capabilities
    jobs.each.capability.uniq
  end

  def additions
    @rbcm.group_additions.select{ |group, additions|
      memberships.include? group
    }.values.flatten(1)
  end

  def to_s
    [ "\e[30;106m\e[1m\ \ #{@name}\ \ \e[0m",
      "\ \ MEMBERSHIPS #{@memberships}",
      "\ \ TRIGGERED #{@triggered}"
    ].join "\n"
  end
end
