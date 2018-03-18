class Job
  include Capabilities
  attr_reader :commands

  def initialize capability, params
    @capability = capability
    @params = params
    @commands = []
  end

  def run
    self.send @capability, *@params
  end
end
