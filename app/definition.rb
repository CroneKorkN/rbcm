# runs a definition and catches jobs
# accepts Proc and provides job list

class Definition
  attr_reader :definition

  def initialize definition
    @definition = definition
  end

  def jobs
    instance_eval &@definition unless @jobs
  end

  def method_missing capability, *params, &block
    @jobs << Job.new(capability, params)
  end
end
