class RBCM::Node
  attr_reader   :jobs, :files, :name, :remote, :rbcm, :cache
  attr_accessor :actions, :memberships, :triggered, :providers

  def initialize rbcm:, name:, project_file:
    @rbcm = rbcm
    @name = name
    @project_file = project_file
    @remote = RBCM::Node::Remote.new self
    @files = RBCM::Node::NodeFilesystem.new self, overlays: @remote.files
    @actions = RBCM::ActionList.new
    @memberships = []
    @jobs = RBCM::JobList.new
    @env = {
      node: self,
      rbcm: @rbcm,
      instance_variables: {},
      class_variables: {},
      jobs: @jobs,
      checks: [],
    }
    @actions = []
    @cache = {
      checks: {},
      targets: [],
      triggered: [],
    }
  end
  
  def parse
    jobs.each.run @env
  end
  
  def to_str
    name.to_s
  end
  
  private
end 
