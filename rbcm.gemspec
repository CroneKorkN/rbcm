Gem::Specification.new do |spec|
  spec.name        = 'rbcm'
  spec.version     = '0.0.0'
  spec.date        = '2018-03-21'
  spec.summary     = "Ruby Config Management"
  spec.description = "manage your servers via simple config-files"
  spec.authors     = ["Martin Wiegand"]
  spec.email       = 'martin@wiegand.tel'
  spec.files       = [
    "lib/command.rb",
    "lib/command_list.rb",
    "lib/definition.rb",
    "lib/definition_file.rb",
    "lib/execution.rb",
    "lib/file.rb",
    "lib/group.rb",
    "lib/job.rb",
    "lib/lib.rb",
    "lib/node.rb",
    "lib/rbcm.rb",
    "lib/remote.rb",
  ]
  spec.executables << 'rbcm'
  spec.homepage    = 'https://github.com/CroneKorkN/rbcm'
  spec.license     = 'MIT'
  spec.add_runtime_dependency 'quickeach', '= 0.1.0'
end
