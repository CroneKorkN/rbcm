class Node::Filesystem
  def initialize node, overlays: false
    @node = node
    @underlying = overlays
    @files = {}
  end

  def [] path
    if @underlying
      @files[path] || @underlying[path]
    else
      @files[path] ||= download path #Node::File.new path: path, file_system:  self
    end
  end

  def []= path, content
    raise "ERROR: dont change remote fs" unless @underlying
    @files[path] = content
  end

  def download path
    log "DOWNLOADING #{@node.name}: '#{path}'"
    response = @node.remote.execute("cat '#{path}'")
    response = "" if response.exitstatus != 0
    response
  end
end
