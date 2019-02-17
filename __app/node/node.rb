class RBCM::Node
  attr_reader   :jobs, :definitions, :files, :name, :remote, :rbcm, :sandbox,
                :path
  attr_accessor :actions, :memberships, :triggered, :providers

  def initialize rbcm, name, path
    @rbcm = rbcm
    @name = name
    @path = path
    @definitions = []
    @providers = []
    @sandbox = RBCM::Node::Sandbox.new self
    @remote = RBCM::Node::Remote.new self
    @files = RBCM::Node::NodeFilesystem.new self, overlays: @remote.files
    @actions = RBCM::ActionList.new
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

  def to_str
    name.to_s
  end
end
