

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
    addon = RBCM::Addon.new type: type, name: name
    @env[:rbcm].projects.append  addon
    @env[:rbcm].definitions.push *addon.definitions.flatten
    @env[:rbcm].jobs.push        *addon.jobs.flatten
  end
end
