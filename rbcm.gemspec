Gem::Specification.new do |spec|
  spec.name          =  'rbcm'
  spec.version       =  '0.0.13'
  spec.date          =  '2018-03-21'
  spec.summary       =  "Ruby Config Management"
  spec.description   =  "manage your servers via simple config-files"
  spec.authors       =  ["Martin Wiegand"]
  spec.email         =  'martin@wiegand.tel'
  spec.executables   << 'rbcm'
  spec.homepage      =  'https://github.com/CroneKorkN/rbcm'
  spec.license       =  'MIT'
  spec.files         =  Dir['app/**/*.rb']
  spec.require_paths = ['app/']
  spec.add_runtime_dependency 'diffy',      "= 3.2.0"
  spec.add_runtime_dependency 'mustache',   "= 1.0.2"
  spec.add_runtime_dependency 'ipaddress',  "= 0.8.2"
  spec.add_runtime_dependency 'unix-crypt', "= 1.3.0"
  spec.add_runtime_dependency 'net-ssh',    "= 4.2.0"
  spec.add_runtime_dependency 'net-scp',    "= 1.2.2.rc2"
  spec.add_runtime_dependency 'git',        "= 1.4.0"
  spec.add_runtime_dependency 'pry',        "= 0.11.3"
end
