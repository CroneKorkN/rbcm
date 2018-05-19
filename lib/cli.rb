class CLI
  def initialize rbcm, params
    options = Options.new params
    puts "\n================ RBCM starting ================\n\n"
    rbcm.parse
    rbcm.approve
    rbcm.apply
  end

  def check command

  end

  def approve command

  end
end
