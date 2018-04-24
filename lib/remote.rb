class Remote
  def initialize host
    @host = host
  end

  def execute command
    Execution.new command, @host
  end

end
