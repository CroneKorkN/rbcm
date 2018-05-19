Gem::Specification.new do |spec|
  spec.name        =  'rbcm'
  spec.version     =  '0.0.0'
  spec.date        =  '2018-03-21'
  spec.summary     =  "Ruby Config Management"
  spec.description =  "manage your servers via simple config-files"
  spec.authors     =  ["Martin Wiegand"]
  spec.email       =  'martin@wiegand.tel'
  spec.executables << 'rbcm'
  spec.homepage    =  'https://github.com/CroneKorkN/rbcm'
  spec.license     =  'MIT'
  spec.files       =  [
    "lib/action.rb",
    "lib/action_list.rb",
    "lib/array_hash.rb",
    "lib/core.rb",
    "lib/command.rb",
    "lib/definition_file.rb",
    "lib/file_system.rb",
    "lib/file_action.rb",
    "lib/job.rb",
    "lib/lib.rb",
    "lib/node.rb",
    "lib/params.rb",
    "lib/rbcm.rb",
    "lib/remote.rb",
    "lib/sandbox.rb",
    "lib/template.rb",
  ]
  spec.add_runtime_dependency 'diffy',     "= 3.2.0"
  spec.add_runtime_dependency 'mustache',  "= 1.0.2"
  spec.add_runtime_dependency 'net-ssh',   "= 4.2.0"
  spec.add_runtime_dependency 'net-scp',   "= 1.2.1"
  spec.add_runtime_dependency 'quickeach', "= 0.1.0"
end
