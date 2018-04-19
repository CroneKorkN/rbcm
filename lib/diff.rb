class Diff
  def initialize node
    intentions = [
      either: [],
      neccessary: [],
      unneccessary: [],
    ]
    node.commands.each do |command|
      if @capability in [:file, :manipulate]
        # diff files
      else
        if command.check.defined?
          unless command.check
            intentions[:neccessary] << command.line
          else
            intentions[:unneccessary] << command.line
          end
        else
          intentions[:either] << command.line
        end
      end
    end
  end
end
