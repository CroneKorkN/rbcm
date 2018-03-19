# contains parameters send to capabilities
# used to read configuration via "?"-suffix methods

class Job
  attr_reader :capability, :params

  def initialize capability, params
    @capability = capability
    @params = params
  end

  def ordered_params
    named_params? ? @params[0..-2] : @params
  end

  def named_params
    @params.last if named_params?
  end

  def named_params?
    @params.last.class == Hash
  end
end
