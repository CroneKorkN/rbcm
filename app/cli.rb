class RBCM::CLI
  def initialize argv
    @rbcm = rbcm = RBCM::Core.new argv[0] || `pwd`.chomp
  end
end
