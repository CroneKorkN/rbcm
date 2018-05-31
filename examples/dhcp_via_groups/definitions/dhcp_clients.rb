group :dhcp_clients do
  host = @name
  ip = ip?(:v4).first
  mac = ip?(:mac).first
  group :dhcp_servers do
    dhcpd host: host,
      mac: mac,
      ip:  ip
  end
end
