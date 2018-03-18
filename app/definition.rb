# runs a definition and catches jobs
# accepts Proc and provides job list

class Definition
  attr_reader :jobs

  def initialize definition
    @jobs = []
    instance_eval &definition
  end

  def method_missing capability, *params, &block
    @jobs << Job.new(capability, params)
  end
end
