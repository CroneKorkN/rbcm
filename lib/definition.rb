# runs a definition and catches jobs
# accepts definition-Proc and provides definition-Proc and job list

class Definition
  attr_reader :content, :jobs

  def initialize content
    @content = content
    @jobs = []
    instance_eval &@content
  end

  private

  # prevent strange p and puts behavious within node block
  def p *params; end
  def puts *param; end

  def method_missing capability, *params, &block
    @jobs << Job.new(capability, params)
  end
end
