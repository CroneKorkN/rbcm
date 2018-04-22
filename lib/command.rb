class Command
  include Params
  attr_reader :line, :capability, :params,
    :dependencies, :unneccessary, :approved

  def initialize line:, capability:, params:, dependencies:, check: nil
    @line = line
    @capability = capability
    @params = params
    @dependencies = [:file] + [dependencies].flatten - [capability]
    @check = check
    @unneccessary = nil
    @approved = nil
  end

  def check node
    @node = node
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
    puts "check: #{@check}"
    puts "unneccessary: #{@unneccessary}"
    if @unneccessary
      p "UNNECCESSARY"
      return
    else
      print "APROVE:"
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
