class Node
  attr_reader   :jobs, :definitions, :files, :name, :remote, :rbcm, :sandbox
  attr_accessor :actions, :memberships, :triggered

  def initialize rbcm, name
    @rbcm = rbcm
    @name = name
    @definitions = []
    @sandbox = Node::Sandbox.new self
    @remote = Node::Remote.new self
    @files = Node::NodeFilesystem.new self, overlays: @remote.files
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
    @sandbox.evaluate definitions.flatten.compact
  end

  def capabilities
    jobs.each.capability.uniq
  end

  def additions
    @rbcm.group_additions.select{ |group, additions|
      memberships.include? group
    }.values.flatten(1)
  end
end
