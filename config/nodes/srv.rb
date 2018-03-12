nodes "srv.ckn.li" do
  ip "aaa"
  ip ["bbb", "ccc"]
  apt install: [
    :apache2, :postgresql, :'redis-server',
    :htop, :iotop,
    :'zfs-dkms'
  ]

  service :apache2, :restart
  service :postgres, :enable
  service :test, :stop

  apt install: :blablub

  hostname "name", :pampa, test: 87587, test2: :iugg, test3: :iugsaiusg
  hostname "name", :pampa, test: 87587, test2: :iugg, test3: :iugsaiusg

  apt? :install
  ubuntu? :ubuntu
  service?
end
