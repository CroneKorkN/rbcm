class RBCM::Node
  attr_reader   :rbcm, :cache, :name, :remote
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
      @rbcm.jobs.capability(:node).select{|job| job.params.first == @name}.collect{|job| job.stack}.flatten # TODO
  end
  
  def actions
    @actions ||= \
    jobs.collect do |job|
      if job.name == :file
        RBCM::Action::File.new node: self, job: job
      elsif job.name == :dir
        p "==================================="
        p job.parent.path 
        nil
      elsif job.name == :run
        RBCM::Action::Command.new node: self, job: job
      end
    end.flatten.compact
  end
  
  def to_s
    name.to_s
  end
end 
