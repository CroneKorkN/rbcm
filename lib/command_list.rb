module CommandList
  def resolve
    @commands = []
    self.each do |command|
      resolve_command command
    end
    @commands.uniq
  end

  private

  def resolve_command this
    self.select{ |command|
      this.dependencies.include? command.capability
    }.each{ |command|
      resolve_command command
    }
    @commands << this
  end
end
