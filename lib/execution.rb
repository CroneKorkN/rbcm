require 'open3'

class Execution
  attr_reader :stdout, :stderr, :status

  def initialize session, command: nil
    ssh.exec!(@command) do |ch, stream, data|
      @status = stream == :stdout ? 0 : 1
      @stdout = data if stream == :stdout
      @stderr = data if stream == :stderr
    end
    return self
  end

  def success?
    @status == 0
  end
end
