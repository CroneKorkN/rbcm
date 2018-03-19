# runs a definition and catches jobs
# accepts definition-Proc and provides definition-Proc and job list

class Definition
  attr_reader :definition, :jobs

  def initialize definition
    @definition = definition
    @jobs = []
    instance_eval &@definition
  end

  def method_missing capability, *params, &block
    @jobs << Job.new(capability, params)
  end
end
