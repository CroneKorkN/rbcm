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
    @obsolete = @node.remote.execute(@check).success? if @check
    if @obsolete == nil
      puts "EITHER: #{@line} (#{@check})"
    elsif @obsolete == false
      puts "YES:    #{@line} (#{@check})"
    elsif @obsolete == true
      puts "NO:     #{@line} (#{@check})"
    end
  end

  def approve
    puts "---------------------------------------------------------------------"
    print "OBSOLETE " if @obsolete
    puts "COMMAND: #{@line} "
    puts "chain: #{@chain.join(" > ")}"
    puts "check: #{@check}"
    puts "obsolete: #{@obsolete} - #{@obsolete.class}"
    if @obsolete
      puts "OBSOLETE ============================================================"
      return
    else
      print "APROVE (y/N): "
      @approved = STDIN.gets == "y"
      puts "APPROVED" if @approved
    end
  end

  def apply
    pp @node.remote.execute @line
  end

  def to_s
    "#{@capability} #{@params.to_s[1..-2]}\n  #{@line}"
  end
end
