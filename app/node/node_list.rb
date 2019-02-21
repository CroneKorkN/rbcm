# holds a definition on form of a proc to be executed in a nodes sandbox

class RBCM::NodeList < Array
  def [] query
    return super if query.class == Integer
    find{|node| node.name == query}
  end
  
  def []= _, node
    append node unless one?{|n| n.name == node.name}
  end
end
