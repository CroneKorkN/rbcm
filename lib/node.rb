class Node
  attr_reader :jobs, :definitions

  def initialize name
    @name = name
    @definitions = []
  end

  def << definition
    definition.node = self
    @definitions << definition
  end

  def parse
    definitions.each.parse
    capabilities.each do |capability|
      final_definition.send "#{capability}!"
    end
  end

  def check
    commands.each.check
  end

  def approve
    commands.each.approve
  end

  def jobs
    @jobs ||= definitions.each.jobs.flatten(1)
  end

  def commands
    @commands ||= definitions.each.commands.flatten(1)
  end

  def capabilities
    @capabilities ||= jobs.each.capability.uniq
  end

  def remote
    @remote ||= Remote.new @name
  end

  def final_definition
    @final_definition ||= (definitions << Definition.new(self)).last
  end

  def memberships
    definitions.each.memberships.flatten(1)
  end

  def affected_files
    @affected_files ||= commands.select{ |command|
      command.capability == :file
    }.collect{ |command|
      command.ordered_params.first
    }
  end
end
