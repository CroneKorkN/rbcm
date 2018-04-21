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
    definitions.each{|definition| definition.parse}
  end

  def jobs
    @jobs ||= definitions.collect{|definition| definition.jobs}
  end

  def commands
    @definitions ||= definitions.collect{|definition| definition.commands}
  end

  def capabilities
    @capabilities ||= jobs.collect{|job| job.capability}
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
