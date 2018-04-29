class FileSystem
  def initialize node, mirror: false
    @node = node
    @mirror = mirror
    @files = {}
  end

  def [] path
    return @files[path] ||= @mirror[path] if @mirror
    log "DOWNLOADING '#{path}'"
    @files[path] ||= @node.remote.execute("cat '#{path}'")
  end

  def []= path, content
    @files[path] = content
  end
end
