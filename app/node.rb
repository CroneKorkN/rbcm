require file

class Node
  def initialize name
    @jobs = []
    @commands = []
    import_recipes
  end

  def add_job job
    @jobs.append! job
  end

  def apply node
    # collect commands
    @jobs.collect {call}
    @commands.collect {run_at_node}
  end

  def run command
    @commands << command
  end

  private

  def run_at_node
    # ssh ....
  end

  def respond_to_missing?(name, include_private = false)
    require "../recipes/#{name}" unless self.methods.include? name
    super
  end

  #TODO require recipes on domand on NameError
  # https://stackoverflow.com/questions/5513558/executing-code-for-every-method-call-in-a-ruby-module
  # http://blog.honeybadger.io/how-to-try-again-when-exceptions-happen-in-ruby/
  # http://ruby-doc.org/core-2.5.0/BasicObject.html
  #def import_recipes
  #  Dir[
  #    File.join(File.dirname(__FILE__), '..', 'lib') + "**/*.rb"
  #  ].each { |file|
  #    include self.class.const_get(
  #      File.basename(file).gsub('.rb', '').split("_").map{|ea| ea.capitalize}.to_s
  #    )
  #  }
  #end
end
