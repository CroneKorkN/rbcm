class FileList < Hash
  def initialize node
    @node = node
  end

  def << path, action
    self[path] || = File.new node, path
    self[path] << action
  end
end
