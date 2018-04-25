# ToDo: approve all changes to a spicific file at once

class Command
  include Params
  attr_reader :line, :params, :dependencies, :obsolete,
    :approved, :triggered_by

  def initialize node:, line:, params:, dependencies:,
      check: nil, chain:, triggered_by: nil, trigger: nil
    @chain_cache = chain
    @capability = chain.last
    @node = node
    @line = line
    @params = params
    @dependencies = [:file] + [dependencies].flatten - [chain.last]
    @check = check
    @obsolete = nil
    @approved = nil
    @trigger = trigger
    @triggered_by = triggered_by
  end

  def check
    print "CHECKING $>_ #{@check}"
    @obsolete ||= @node.remote.execute(@check).success? if @check
    puts @obsolete ? " OK" : " CHANGE"
    @obsolete
  end

  def approve
    puts self
    if @obsolete
      return
    else
      print "APROVE (g,y/N): " # o: apply to ahole group
      @approved = STDIN.gets.chomp == "y"
      @node.triggered << @trigger
    end
  end

  def apply
    p 111111
    p @node.remote.execute @line
  end

  def to_s
    [
      @obsolete ? "\e[30;42m" : "\e[30;43m",
      "\e[1m  #{@node.name} > #{@chain_cache.join(" > ")}  \e[0m\n",
      "\ \ \e[4m#{@params.to_s[1..-2]}\e[0m\n",
      "\ \ $>_ \e[1m#{@line}\e[0m \e[2mUNLESS #{@check}\e[0m\n",
      "trigger: #{@trigger}, triggered_by: #{@triggered_by}"
    ].join
  end
end
