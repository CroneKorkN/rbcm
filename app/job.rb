class Job < Capabilities
  def initialize capability, params
    @capability = capability
    @params = params
    @dependency_cache = []
  end

  def commands
    @commands = []
    self.send @capability, *@params
    return @commands
  end
end
