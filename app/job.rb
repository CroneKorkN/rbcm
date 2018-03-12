class Job
  attr_accessor :params
  attr_accessor :dependencies

  def initialize capability, params, dependencies: dependencies
    @capability = capability
    @params = params
    @dependencies = dependencies
  end

  def run
    send "__#{@capability}", @params
  end
end
