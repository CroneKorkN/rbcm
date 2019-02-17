class Binding
  def to_h
    local_variables.select{|name| not name.match? /^_.*/}.collect{|name| [name, local_variable_get(name)]}.to_h
  end
end
