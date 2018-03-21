class Remote
  def initialize name
    @name = name
  end

  def execute! command
    `ssh root@#{@name} #{command}`
    `ssh root@#{@name} 'echo \'#{command}\' >> ~/rbcm.log'`
  end

  def state
    execute! "cat ~/rbcm.state"
  end

  def push file, content

  end

  def pull file
    
  end
end
