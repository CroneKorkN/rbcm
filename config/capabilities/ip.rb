def ip addresses
  [addresses].flatten.each do |address|
    run "ip #{address}"
  end
end
