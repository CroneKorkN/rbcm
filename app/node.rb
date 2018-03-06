require file

class Node
  def initialize name
    @recipes = []
    # include all recipies
    Dir[
      File.join(File.dirname(__FILE__), '..', 'lib') + "**/*.rb"
    ].each { |file|
      include self.class.const_get(
        File.basename(file).gsub('.rb', '').split("_").map{|ea| ea.capitalize}.to_s
      )
    }
  end

  def add_recipes recipes
    @recipes.append! recipes
  end

  def apply node
    node[recipes].each do |recipe|
      recipe.call
    end
  end
end
