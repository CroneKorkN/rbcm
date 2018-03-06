class Node
  def initialize
    Dir[
      File.join(File.dirname(__FILE__), '..', 'lib') + "**/*.rb"
    ].each { |file|
      require file
      include self.class.const_get(
        File.basename(file).gsub('.rb', '').split("_").map{|ea| ea.capitalize}.to_s
      )
    }
  end

  def apply
  end
end
