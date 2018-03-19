def apt test=nil, install: nil
  [install].flatten.each do |package|
    run "apt install #{package}"
  end if install
end
