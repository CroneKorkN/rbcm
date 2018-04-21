# runs a definition and catches jobs
# accepts definition-Proc and provides definition-Proc and job list

class Definition < Capabilities
  def initialize content
    @content = content
    @jobs = []
    @commands = []
    @dependency_cache = []
    instance_eval &@content
  end
end
