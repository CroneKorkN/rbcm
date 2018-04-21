class Node
  attr_reader :jobs, :definitions, :memberships

  def initialize name
    @name = name
    @memberships = []
    @definitions = []
  end

  def << definition
    @definitions << definition
  end

  def parse
    definitions.each.parse
    definition = Definition.new
    capabilities.each do |capability_name|
      definition.send "#{capability_name}!"
    end
    self << definition
  end

  def jobs
    @jobs ||= definitions.each.jobs
  end

  def commands
    @definitions ||= definitions.each.commands
  end

  def capabilities
    @capabilities ||= jobs.each.capability
  end

  def remote
    @remote ||= Remote.new @name
  end

  def affected_files
    @affected_files ||= commands.select{ |command|
      command.capability == :file
    }.collect{ |command|
      command.ordered_params.first
    }
  end
end
