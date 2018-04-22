# ToDo: approve all changes to a spicific file at once

class Command
  include Params
  attr_reader :line, :capability, :params,
    :dependencies, :unneccessary, :approved

  def initialize node:, line:, capability:, params:, dependencies:, check: nil
    @node = node
    @line = line
    @capability = capability
    @params = params
    @dependencies = [:file] + [dependencies].flatten - [capability]
    @check = check
    @unneccessary = nil
    @approved = nil
  end

  def check
    @unneccessary = @node.remote.execute!(@check).success? if @check
    if @unneccessary == nil
      puts "EITHER: #{@line} (#{@check})"
    elsif @unneccessary == false
      puts "YES:    #{@line} (#{@check})"
    elsif @unneccessary == true
      puts "NO:     #{@line} (#{@check})"
    end
  end

  def approve
    puts "---------------------------------------------------------------------"
    puts "COMMAND: #{@line}"
    puts "capability: #{@capability}"
    puts "check: #{@check}"
    puts "unneccessary: #{@unneccessary}"
    if [:file, :manipulate].include? @capability
      #File.new @node, self
    end
    if @unneccessary
      p "UNNECCESSARY"
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

  def to_s
    "#{@capability} #{@params.to_s[1..-2]}\n  #{@line}"
  end
end
