class RBCM::Node
  attr_reader   :jobs, :definitions, :files, :name, :remote, :rbcm, :sandbox,
                :path
  attr_accessor :actions, :memberships, :triggered, :providers, :definitions

  def initialize project: project, name: name, project_file: project_file
    @project = project
    @name = name
    @project_file = project_file
    @remote = RBCM::Node::Remote.new self
    @files = RBCM::Node::NodeFilesystem.new self, overlays: @remote.files
    @actions = RBCM::ActionList.new
    @memberships = []
    @jobs = []
    @env = {
      node: self,
      project: @project,
      instance_variables: [],
      class_variables: [],
      jobs: @jobs,
    }
    @actions = []
  end
  
  def parse
    jobs.each.run @env
  end
  
  def to_str
    name.to_s
  end
  
  private
end
