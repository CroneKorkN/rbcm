# holds a definition on form of a proc to be executed in a nodes sandbox

class RBCM::CheckList < Array
  def [] query
    return super if query.class == Integer
    find{|check| check.hash == query}
  end
  
  def []= _, node
    append node unless one?{|n| n.hash == node.name}
  end
end
