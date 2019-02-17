# holds a definition on form of a proc to be executed in a nodes sandbox

class RBCM::DefinitionList < Array
  # def initialize array=[]
  #   array.each{|element| insert -1, element}
  # end
  
  def type query
    self.class.new find_all{ |definition| definition.type == query}
  end 
  
  def name query
    self.class.new find{ |definition| definition.name == query}
  end
end
