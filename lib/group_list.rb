class GroupList < Hash
  def [] group
    self[group] = [] unless self[group]
    super
  end
end
