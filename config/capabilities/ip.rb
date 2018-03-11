def ip addresses
  addresses.each do |address|
    run "ip #{address}"
  end
end
