class Node::File
  def initialize path:, filesystem:
    @path       = path
    @filesystem = filesystem
  end

  attr_writer :content, :mode

  def content
    return @content if @content
    log "DOWNLOADING #{@filesystem.node.name}: '#{@path}'"
    response = @filesystem.node.remote.execute("cat '#{@path}'")
    response = "" if response.exitstatus != 0
    @content = response
  end

  def mode
    @mode ||= @filesystem.node.remote.execute(
      "stat -c \"%a\" * '#{@path}'"
    ).chomp.chomp.to_i
  end
end
