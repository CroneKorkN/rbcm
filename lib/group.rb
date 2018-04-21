class Group
  @@groups = {}

  def self.[]= name, definition_content
    @@groups[name] = definition_content
  end

  def self.[] name
    @@groups[name]
  end

  def self.all
    @@groups
  end
end
