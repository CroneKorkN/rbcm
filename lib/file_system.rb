class FileSystem
  def initialize node, mirror: false
    @node = node
    @mirror = mirror
    @files = {}
  end

  def [] path
    if @mirror
      @mirror[path]
    elsif not @files[path]
      log "DOWNLOADING '#{path}'" unless @mirror
      result = @node.remote.execute("cat '#{path}'")
      @files[path] = result.exitstatus == 0 ? result : ""
    end
    return @files[path]
  end

  def []= path, content
    @files[path] = content
  end
end
