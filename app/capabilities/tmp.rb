

def node *_ 
  yield

end

def group *_ 
  yield
end

def addon branch: "master", **named
  raise "illegal project source: #{keys}" if (
    keys = named.keys - [:github, :dir, :file]
  ).any?
  named.each do |type, name|
    addon = RBCM::Addon.new(
      type: type, 
      name: name, 
      rbcm: @job.rbcm,
    )
    @job.rbcm.projects.append  addon
  end
end
