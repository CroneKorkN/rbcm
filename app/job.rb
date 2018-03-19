# contains parameters send to capabilities
# used to read configuration via "?"-suffix methods

class Job
  include Params
  attr_reader :capability, :params

  def initialize capability, params
    @capability = capability
    @params = params
  end
end
