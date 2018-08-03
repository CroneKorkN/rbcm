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
