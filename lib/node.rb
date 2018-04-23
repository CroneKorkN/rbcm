class Node
  attr_reader :jobs, :definitions, :files

  def initialize name
    @name = name
    @definitions = []
    @files = {}
  end

  def << definition
    definition.node = self
    @definitions << definition
  end

  def parse
    definitions.each.parse
    capabilities.each{|capability| final_definition.send "#{capability}!"}
    jobs.select{|job| job.capability == :file}.each do |job|
      path = job.params[0]
      @files[path] = File.new self, path unless @files[path]
      @files[path] << job.params
    end
  end

  def check
    commands.each.check
  end

  def approve
    commands.each.approve
  end

  def jobs
    definitions.each.jobs.flatten(1)
  end

  def commands
    definitions.each.commands.flatten(1)
  end

  def capabilities
    jobs.each.capability.uniq
  end

  def remote
    @remote ||= Remote.new @name
  end

  def final_definition
    @final_definition ||= (self << Definition.new).last
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
