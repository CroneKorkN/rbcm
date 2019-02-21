class RBCM::Node
  attr_reader   :rbcm, :cache, :name
  attr_accessor :jobs, :actions

  def initialize rbcm:, name:
    @rbcm = rbcm
    @name = name
    @remote = RBCM::Node::Remote.new self
    @files = RBCM::Node::NodeFilesystem.new self, overlays: @remote.files
    @jobs = RBCM::JobList.new
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
