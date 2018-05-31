def systemctl enable: nil, restart: nil, reload: nil
    run "systemctl enable #{enable}",
      check: "systemctl is-enabled #{enable}" if enable
    run "systemctl restart #{restart}"        if restart
    run "systemctl reload #{reload}"          if reload
  end
end
