class GroupList
  def initialize
    @groups = {}
  end

  def []= group, definition
    @groups[group] = [] unless @groups[group]
    @groups[group] << definition
  end

  def [] group
    @groups[group] = [] unless @groups[group]
    @groups[group]
  end
end
