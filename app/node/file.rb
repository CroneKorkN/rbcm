class Node::File
  def initialize path:, filesystem:
    @path       = path
    @filesystem = filesystem
  end

  attr_writer :content, :mode

  def content
    @content ||= @filesystem.download @path
  end

  def mode
    @mode ||= @filesystem.mode @path
  end
end
