# ToDo: approve all changes to a spicific file at once

class Command
  include Params
  attr_reader :line, :params, :dependencies, :obsolete,
    :approved, :triggered_by, :chain, :capability
  attr_writer :approved

  def initialize node:, line:, params:, dependencies:,
      check: nil, chain:, triggered_by: nil, trigger: nil
    @chain = chain
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

  def siblings
    @node.rbcm.commands.select{ |command|
      command.chain == @chain and
      command.capability == @capability and
      command.params == @params
    }
    []
  end

  def check
    log "CHECKING $>_ #{@check}"
    if @capability == :file
      @node.files[@params[0]] = named_params[:content]
      @obsolete = diff == ""
    elsif @check
      @obsolete = @node.remote.execute(@check).success?
    else
      @obsolete = false
    end
  end

  def approve
    # check if neccessary
    check unless [true, false].include? @obsolete
    # print info
    puts self
    puts diff
    # finish if obsolete
    return if @obsolete
    # interact
    print "APROVE (g,y/N): " # o: apply to ahole group
    @approved = [:g, :y].include? STDIN.gets.chomp.to_sym
    siblings.each.approved = true if @approved == :g
    @node.triggered << @trigger
  end

  def apply
    p @node.remote.execute @line
  end

  def diff
    if @capability == :file
      path = @params[0]
      @diff ||= [
        @node.remote.files[path],
        @node.files[path]
      ].join(">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>")
      #return @diff ||= Diffy::Diff.new(
      #  @node.remote.files[path],
      #  @node.files[path]
      #).diff
    else
      "\ \ $>_ \e[1m#{@line}\e[0m \e[2m CHECK #{@check}\e[0m"
    end
  end

  def to_s
    [ @obsolete ? "\e[30;42m" : "\e[30;43m",
      "\e[1m  #{@node.name} > #{@chain.join(" > ")}  \e[0m",
      "\n\ \ \e[4m#{@params.to_s[1..-2]}\e[0m",
      "\n\ \ siblings: #{siblings.count}, trigger: #{@trigger}, triggered_by: #{@triggered_by}"
    ].join
  end
end
