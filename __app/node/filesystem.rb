class RBCM::Node::NodeFilesystem
  def initialize node, overlays: false
    @node = node
    @underlying = overlays
    @files = {}
  end

  attr_reader :node

  def [] path
    if @underlying
      @files[path] || @underlying[path]
    else
      @files[path] ||= RBCM::Node::NodeFile.new path: path, filesystem: self
    end
  end
end
