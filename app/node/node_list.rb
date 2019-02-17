# holds a definition on form of a proc to be executed in a nodes sandbox

class RBCM::NodeList < Array
  def name query
    self.class.new find{|node| node.name == query}
  end
end
