class RBCM::Node
  attr_reader   :jobs, :files, :name, :remote, :rbcm, :cache
  attr_accessor :actions, :memberships, :triggered, :providers

  def initialize rbcm:, name:
    @rbcm = rbcm
    @name = name
    @remote = RBCM::Node::Remote.new self
    @files = RBCM::Node::NodeFilesystem.new self, overlays: @remote.files
    @actions = RBCM::ActionList.new
    @cache = {
      checks: {},
      targets: [],
      triggered: [],
    }
  end
  
  def to_s
    name.to_s
  end
end 
