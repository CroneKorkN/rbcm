class FileSystem
  def initialize node
    @node = node
    @files = {}
  end

  def [] path
    log "downloading '#{path}'"
    @files[path] ||= @node.remote.execute("cat '#{path}'")
  end

  def []= path, content
    @files[path] = content
  end
end

class FileSystemMirror < FileSystem
  def initialize node, mirror
    @node = node
    @mirror = mirror
    @files = {}
  end

  def [] path
    @files[path] ||= @mirror[path]
  end
end
