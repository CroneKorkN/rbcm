class Node::NodeFile
  def initialize path:, filesystem:
    @path       = path
    @filesystem = filesystem
  end

  attr_writer :content, :user, :group, :mode

  def content
    @content ||= (
      log "DOWNLOADING #{@filesystem.node.name}: '#{@path}'"
      response = @filesystem.node.remote.execute("cat '#{@path}'")
      response = "" if response.exitstatus != 0
      response
    )
  end

  def diffable
    "#{content}" +
    "\\" +
    "PERMISSIONS #{user}:#{group} #{mode}"
  end

  def user
    @user ||= @filesystem.node.remote.execute(
      "stat -c '%U' '#{@path}'"
    ).chomp.chomp
  end

  def group
    @group ||= @filesystem.node.remote.execute(
      "stat -c '%G' '#{@path}'"
    ).chomp.chomp
  end

  def mode
    @mode ||= @filesystem.node.remote.execute(
      "stat -c '%a' * '#{@path}'"
    ).chomp.chomp.to_i
  end
end
