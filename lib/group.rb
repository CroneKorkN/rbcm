class Group
  @@groups = {}

  def self.[] name
    @@groups[name]
  end

  def self.<< definition
    @@groups[definition.name] = definition.content
  end
end
