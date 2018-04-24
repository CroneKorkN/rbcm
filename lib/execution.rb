require 'open3'

class Execution
  attr_reader :command, :host, :stdout, :stderr, :status

  def initialize command, host
    @command = command
    @host = host
    puts "ssh root@#{@host} #{command}"
    #@stdout, @stderr, @status = Open3.capture3 "ssh root@#{@host} #{command}"
    Net::SSH.start(@host, 'root') do |ssh|
      ssh.exec!(@command) do |ch, stream, data|
        if stream == :stderr
          @status = 1
          @stderr = data
        else
          @status = 0
          @stdout = data
        end
      end
    end

    #Net::SCP.start("remote.host.com", "username", :password => "password") do |scp|
    #  scp.upload! StringIO.new("some data to upload"), "/remote/path"
    #end
  end

  def success?
    @status == 0
  end
end
