require 'open3'

class Execution
  attr_reader :command, :host, :stdout, :stderr, :status

  def initialize command, host
    @command = command
    @host = host
    @stdout, @stderr, @status = Open3.capture3 "ssh root@#{@host} #{command}"
  end

  def success?
    @status.success?
  end
end
