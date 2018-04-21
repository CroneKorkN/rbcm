Gem::Specification.new do |spec|
  spec.name        = 'rbcm'
  spec.version     = '0.0.0'
  spec.date        = '2018-03-21'
  spec.summary     = "Ruby Config Management"
  spec.description = "manage your servers via simple config-files"
  spec.authors     = ["Martin Wiegand"]
  spec.email       = 'martin@wiegand.tel'
  spec.files       = [
    "lib/capabilities.rb",
    "lib/command_collector.rb",
    "lib/command_list.rb",
    "lib/command.rb",
    "lib/definition.rb",
    "lib/diff.rb",
    "lib/job.rb",
    "lib/lib.rb",
    "lib/definition_file.rb",
    "lib/node.rb",
    "lib/rbcm.rb",
    "lib/remote.rb",
  ]
  spec.executables << 'rbcm'
  spec.homepage    = 'https://github.com/CroneKorkN/rbcm'
  spec.license     = 'MIT'
end
