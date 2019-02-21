class RBCM::Node
  attr_reader   :rbcm, :cache, :name
  attr_accessor :actions

  def initialize rbcm:, name:
    @rbcm = rbcm
    @name = name
    @remote = RBCM::Node::Remote.new self
    @files = RBCM::Node::NodeFilesystem.new self, overlays: @remote.files
    @cache = {
      checks: {},
      targets: [],
      triggered: [],
    }
  end
  
  def jobs
    RBCM::JobList.new \
      @rbcm.jobs.capability(:node).collect{|job| job.params.first == @name}
    # TODO: filter nestet nodes
  end
  
  def actions
    @actions ||= \
    [*@rbcm.jobs.capability(:file), *@rbcm.jobs.capability(:run)].collect do |job|
      RBCM::Action::File.new node: self, job: job
    end  
  end
  
  def to_s
    name.to_s
  end
end 
