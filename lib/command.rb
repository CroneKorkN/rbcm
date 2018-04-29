# ToDo: approve all changes to a spicific file at once

class Command < Action
  include Params
  attr_reader :line, :params, :dependencies, :obsolete,
    :approved, :triggered_by, :chain, :capability, :node
  attr_writer :approved

  def initialize node:, line:, params:, dependencies:,
      check: nil, chain:, trigger: nil, triggered_by: nil
    @chain = chain
    @capability = chain.last
    @node = node
    @line = line
    @params = params
    @dependencies = [:file] + [dependencies].flatten - [chain.last]
    @check = check
    @obsolete = nil
    @approved = nil
    @trigger = [trigger, chain.last].flatten(1)
    @triggered_by = triggered_by
  end

  def siblings
    @node.rbcm.commands.select{ |command|
      command.chain[1..-1] == @chain[1..-1] and command.line == @line
    } - [self]
  end

  def check
    log "CHECKING $>_ #{@check}"
    path = @params[0]
    if @capability == :file
      @node.files[path] = named_params[:content]
      @obsolete = @node.remote.files[path].chomp == @node.files[path].chomp
    elsif @check
      @obsolete = @node.remote.execute(@check).exitstatus == 0
    else
      @obsolete = false
    end
  end

  def approve
    # check if neccessary
    check unless [true, false].include? @obsolete
    # print info
    puts self
    puts diff unless @capability == :file
    # finish if obsolete
    return if @obsolete or @approved
    puts diff if @capability == :file
    # interact
    print "APROVE (g,y/N): " # o: apply to ahole group
    input = STDIN.gets.chomp.to_sym
    @approved = [:g, :y].include? input
    siblings.each.approved = true if input == :g
    @node.triggered << @trigger
  end

  def apply
    response = @node.remote.execute(@line)
    print [ response.exitstatus == 0 ? "\e[30;42m" : "\e[30;101m",
      "\e[1m  #{@chain.join(" > ")}  \e[0m",
      "\n\ \ \e[4m#{@params.to_s[1..-2]}\e[0m",
      "\n\e[3m#{response.to_s.chomp}\e[0m\n"
    ].join
  end

  def diff
    if @capability == :file
      path = @params[0]
      [ @node.remote.files[path],
        @node.files[path]
      ].join("\n>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>\n")
      #return @diff ||= Diffy::Diff.new(
      #  @node.remote.files[path],
      #  @node.files[path]
      #).diff
    else
      "\ \ $>_ \e[1m#{@line}\e[0m\e[2m CHECK #{@check}\e[0m"
    end
  end

  def to_s
    [ @obsolete ? "\e[30;42m" : "\e[30;43m",
      "\e[1m\ \ #{@chain.join(" > ")}  \e[0m",
      @trigger.any? ? " triggers \e[30;46m\e[1m #{@trigger.join(", ")} \e[0m" : "",
      siblings.any? ? "\n\ \ siblings: #{siblings.each.node.each.name.join(", ")}" : "",
      "\n\ \ \e[4m#{@params.to_s[1..-2][0..160]}#{" …" if @params.to_s.length > 160}\e[0m",
    ].join
  end
end
