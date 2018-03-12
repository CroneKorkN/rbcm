def service name, action
  run "systemctl #{action} #{name}"
end
