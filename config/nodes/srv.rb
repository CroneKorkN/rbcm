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
  apt "JODEL"

  file "/matchorator", mode: 777

  ubuntu :trusty

  p ubuntu?

  if apt?(:install).include? :blablub
    p "HALLO"
  end
  if apt?(:install).include? :blablddub
    p "HALLO222"
  end

  postgres db: "hallodb"
end
