def dhcp server=nil, host: nil, mac: nil, ip: nil, conf: nil
end

def dhcp!
  conf =  dhcpd? :conf
  conf += dhcpd? with: :host do |host|
    "host '#{host[:host]}' {
      hardware ethernet '#{host[:mac]}';
      fixed-address '#{host[:ip]}';
    }"
  end
  file '/etc/dhcp/dhcpd.conf',
    content: conf.flatten.join("\n"),
    trigger: :dhcp_restart
  apt install: 'isc-dhcp-server'
  systemctl restart: 'isc-dhcp-server',
    triggered_by: :dhcp_restart
end
