class RBCM::CLI
  def initialize argv
    @rbcm = rbcm = RBCM::Core.new argv[0] || `pwd`.chomp
    
    with @rbcm do
      puts "-- projects (#{projects.count}) --\n#{projects.collect(&:path)}"
      puts "-- definitions (#{definitions.count}) --\n#{definitions.collect(&:to_s)}"
      puts "-- jobs (#{jobs.count}) --"
      puts jobs.childless.collect{|job| job.trace.collect(&:to_s).join(" > ")}.join("\n")
      puts "-- nodes (#{nodes.count}) --\n#{nodes.collect(&:name)}"
      puts "-- actions (#{actions.count}) --"
      puts actions.collect{|action| action.job.trace.collect(&:to_s).join(" > ")}.join("\n")
    end
    
    binding.pry
    
  end
end
