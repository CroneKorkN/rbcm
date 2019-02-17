module RBCM::Node::Context
  @@job
  
  # injected cap
  
  def self.method_missing name, *ordered, **named, &block
    job = Job.new name, Params.new(ordered, named, block), parent: @@job
    @@job.jobs.append job
    job.call
  end
end
