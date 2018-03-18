module CommandList
  def resolve commands=nil
    @commands ||= []
    p commands.count if commands
    commands ||= self
    commands.each do |command|
      command.dependencies.each do |dependency|
        @commands += commands - resolve(
          commands.select {|command| command.capability == dependency}
        )
      end
    end
    @commands
  end
end
