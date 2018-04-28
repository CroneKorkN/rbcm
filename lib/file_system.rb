class FileSystem
  def initialize node
    @node = node
    @files = {}
  end

  def [] path
    @files[path] ||= @node.remote.execute("cat '#{path}'") || ""
  end

  def []= path, content
    @files[path] = content
  end
end
