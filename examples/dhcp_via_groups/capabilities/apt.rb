def apt install: nil, remove: nil, purge: false
  run "apt-get install -y #{install}",
    check: "dpkg-query -l #{install}"   if install
  run "apt-get remove -y #{remove} #{'--purge' if purge}",
    check: "! dpkg-query -l #{install}" if remove
end
