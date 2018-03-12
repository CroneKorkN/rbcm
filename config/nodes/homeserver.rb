nodes "homeserver" do
  ip adress: '10.0.0.1'
  apt install: [
    :apache2, :postgresql, :'redis-server',
    :htop, :iotop,
    :'zfs-dkms'
  ]

  if apt?
    puts apt?
  end
end
