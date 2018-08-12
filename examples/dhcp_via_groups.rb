addon github: 'CroneKorkN/rbcm-capabilities-base'

node "client1.example.com" do
  ip "10.0.0.11", mac: "11:11:11:11:11:11"
  group :dhcp_clients
end

node "client2.example.com" do
  ip "10.0.0.12", mac: "22:22:22:22:22:22"
  group :dhcp_clients
end

node "server.example.com" do
  group :dhcp_servers
end

group :dhcp_clients do
  host = @node.name
  ip = ip?(:v4).first
  mac = ip?(:mac).first
  group :dhcp_servers do
    dhcpd host: host,
      mac: mac,
      ip:  ip
  end
end

group :dhcp_servers do
  apt install: :"isc-dhcp-server"
  dhcpd conf: "authoritative;"
  dhcpd conf: "ddns-update-style none;"
  dhcpd conf: "default-lease-time 86400;"
  dhcpd conf: "max-lease-time 604800;"
  dhcpd conf: "option domain-name #{@node.name};"
  dhcpd conf: "option domain-name-servers 8.8.8.8, 8.8.4.4;"
  dhcpd conf: "option routers 10.0.0.1;"
  dhcpd conf: "option subnet-mask 255.255.255.0;"
  dhcpd conf: "subnet 10.0.0.0 netmask 255.255.255.0 {
      range 10.0.0.110 10.0.0.230;
    }"
end
