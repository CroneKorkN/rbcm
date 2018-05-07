class FileSystem
  def initialize node, mirror: false
    @node = node
    @mirror = mirror
    @files = {}
  end

  def [] path
    return @files[path] ||= @mirror[path] if @mirror
    log "DOWNLOADING '#{path}'" unless @mirror
    if (result = @node.remote.execute("cat '#{path}'")).exitstatus == 0
      @files[path] ||= result
    else
      @files[path] ||= ""
    end
  end

  def []= path, content
    @files[path] = content
  end
end
