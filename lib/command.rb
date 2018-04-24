# ToDo: approve all changes to a spicific file at once

class Command
  include Params
  attr_reader :line, :params, :dependencies, :obsolete, :approved

  def initialize node:, line:, params:, dependencies:, check: nil, chain:
    @chain = chain
    @capability = chain.last
    @node = node
    @line = line
    @params = params
    @dependencies = [:file] + [dependencies].flatten - [chain.last]
    @check = check
    @obsolete = nil
    @approved = nil
  end

  def check
    print "CHECKING $>_ #{@check}"
    @obsolete ||= @node.remote.execute(@check).success? if @check
    puts @obsolete ? " OK" : " CHANGE"
    @obsolete
  end

  def approve
    puts "\n\n  \e[1m#{@node.name} > #{@chain.join(" > ")}\e[0m"
    96.times{print "-"}; puts
    puts "\e[4m#{@params.to_s[1..-2]}\e[0m"
    print "OBSOLETE " if @obsolete
    puts "$>_ #{@line} UNLESS #{@check}"
    if @obsolete
      return
    else
      print "APROVE (y/N): "
      @approved = STDIN.gets.chomp == "y"
    end
  end

  def apply
    p 111111
    p @node.remote.execute @line
  end

  def to_s
    "#{@capability} #{@params.to_s[1..-2]}\n  #{@line}"
  end
end
