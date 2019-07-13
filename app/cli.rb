class RBCM::CLI
  def initialize argv
    @rbcm = rbcm = RBCM::Core.new argv[0] || `pwd`.chomp
    
    with @rbcm do
      actions
      puts "-- projects (#{projects.count}) --\n#{projects.collect(&:path)}"
      puts "-- templates (#{templates.count}) --"
      puts templates.collect(&:clean_filename).join(", ")
      puts "-- definitions (#{definitions.count}) --\n#{definitions.collect(&:to_s)}"
      puts "-- jobs (#{jobs.count}) --"
      puts jobs.childless.collect{|job| job.trace.collect(&:to_s).join(" > ")}.join("\n")
      puts "-- nodes (#{nodes.count}) --\n#{nodes.collect(&:name)}"
      puts "-- actions (#{actions.count}) --"
      puts actions.collect{|action| action.job.trace.collect(&:to_s).join(" > ")}.join("\n")
      puts "-- apply (#{actions.count}) --"
      actions.resolve.each do |action|
        puts "---------------------------------------------------------"
        puts "#{action.job.trace.join(" > ")} || #{action.params.first}"
        action.checks.each do |check|
          print "  CHECKING #{check.command}: "
          puts check.result
        end
        puts action.content if action.class == RBCM::Action::File
        if action.checks.any? && action.checks.all?{|check| check.result == 0}
          puts "  UNECCESSARY"
          next
        end
        puts "  << " + action.run!.to_s.split("\n").join("\n  << ")
      end
      #binding.pry
    end
  end
end
