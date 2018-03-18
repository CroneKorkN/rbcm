# runs a definition and catches jobs

class Definition
  attr_reader :jobs

  def initialize definition
    instance_eval definition
  end

  def method_missing
    @jobs << ___
  end
end
