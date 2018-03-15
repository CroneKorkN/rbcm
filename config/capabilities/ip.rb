def ip addresses=nil
  [addresses].flatten.each do |address|
    run "ip #{address}"
  end if addresses
end
