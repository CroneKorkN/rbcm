def service name, action
  needs :apt
  run "systemctl #{action} #{name}"
end
