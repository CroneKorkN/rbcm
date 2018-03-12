nodes "srv.ckn.li" do
  ip "aaa"
  ip ["bbb", "ccc"]
  apt install: [
    :apache2, :postgresql, :'redis-server',
    :htop, :iotop,
    :'zfs-dkms'
  ]

  service :apache2, :restart

  hostname "name", :pampa, test: 87587, test2: :iugg, test3: :iugsaiusg
  hostname "name", :pampa, test: 87587, test2: :iugg, test3: :iugsaiusg
  hostname "name", :pampa, test: 87587, test2: :iugg, test3: :iugsaiusg

  if apt?
    puts apt?
    p "111111111111111"
  end
end
