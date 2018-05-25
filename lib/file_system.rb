class FileSystem
  def initialize node, mirror: false # mirror -> overlay
    @node = node
    @mirror = mirror
    @files = {}
  end

  def [] path
    if @mirror
      @files[path] || @mirror[path]
    else
      log "DOWNLOADING '#{path}'"
      @files[path] ||= download path
    end
  end

  def []= path, content
    raise "ERROR: dont change remote fs" unless @mirror
    @files[path] = content
  end

  def download path
    response = @node.remote.execute("cat '#{path}'")
    response = "" if response.exitstatus != 0
    response
  end
end
