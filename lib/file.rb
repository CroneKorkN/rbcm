class File_
  def initialize node, path
    @actions = []
  end

  def << action
    @actions << action
  end

  def diff
    node.remote.execute!("cat #{path}").stdout
  end
end
