module CommandList
  def resolve_dependencies
    @commands = []
    self.each do |command|
      resolve_command_dependencies command
    end
    @commands
  end

  def resolve_triggers
    @commands = []
    self.each do |command|
      resolve_command_triggers command
    end
    @commands
  end

  private

  def resolve_command_dependencies this
    self.select{ |command|
      this.dependencies.include? command.capability
    }.each{ |command|
      resolve_command_dependencies command
    }
    @commands << this
  end

  def resolve_command_triggers this
    self.select{ |command|
      this.trigger.one?{|trigger| command.triggered_by.include? trigger}
    }.each{ |command|
      resolve_command_triggers command
    }
    @commands << this
  end
end
