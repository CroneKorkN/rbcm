class Node::File
  def initialize path:, file_system:
    @path    = path
    @content = content
    @mode    = mode
  end

  def diff node_file
  end
end
