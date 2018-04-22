class File
  def initialize node, command
    path = command.params[0]
    p node.remote.execute! "mkdir -p $(dirname '/tmp#{path}')"
    if node.remote.execute!("ls #{path}").success?
      p node.remote.execute! "cp #{path} /tmp"
    else
      p node.remote.execute! "touch /tmp#{path}"
    end
    p command.line
    p command.line.sub(path, "/tmp#{path}")
    p "-------------"
    pp node.remote.execute!(command.line.sub(path, "/tmp#{path}"))
    puts "<<<<<<<<"
    node.remote.execute!("cat #{path}").stdout
    puts "---- DIFF ----"
    node.remote.execute!("cat /tmp#{path}").stdout
    puts ">>>>>>>>"
  end
end
