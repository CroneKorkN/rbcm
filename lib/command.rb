# ToDo: approve all changes to a spicific file at once

class Command
  include Params
  attr_reader :line, :capability, :params,
    :dependencies, :obsolete, :approved

  def initialize node:, line:, capability:, params:, dependencies:, check: nil
    @node = node
    @line = line
    @capability = capability
    @params = params
    @dependencies = [:file] + [dependencies].flatten - [capability]
    @check = check
    @obsolete = nil
    @approved = nil
  end

  def check
    @obsolete = @node.remote.execute!(@check).success? if @check
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
    puts "COMMAND: #{@line}"
    puts "capability: #{@capability}"
    puts "check: #{@check}"
    puts "obsolete: #{@obsolete} - #{@obsolete.class}"
    if @obsolete
      puts "OBSOLETE ============================================================"
      return
    else
      print "APROVE (y/N): "
      if STDIN.gets.chomp == "y"
        puts "approved"
        @approved = true
      else
        puts "declined"
        @approved = false
      end
    end
  end

  def apply
    p @node.remote.execute!(@line)
  end

  def to_s
    "#{@capability} #{@params.to_s[1..-2]}\n  #{@line}"
  end
end
