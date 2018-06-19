Ruby Config Management
======================

Navigate into a configuration dir and call rbcm.

```bash
rbcm
```
```bash
rbcm project.rb
```
```bash
rbcm project/
```

## applying

Applying actually passes three steps: checking, approving and execution.

### 1/3 check

Rbcm compares the affected files and executes the action-checks. Unneccessary
actions are marked and will be skipped in the approvemnt process.

### 2/3 approve

The user approves each action interactively.
 - identical actions on multiple nodes can be approved at once by choosing "o"
 - multiple changes to a file can be approved individually by choosing "i"

### 3/3 execute

All approved actions are being executed.

# documentation

Rbcm expects to be called from within a project directory.

## capabilities

Nodes are defined by calling capabilities. Capabilities are user defined methods
residing in project directory. Each capability may have a
second incarnation with a bang suffix ("cap!"). The bang version is called once
on each node if the node called the non-bang-version before.

```ruby
def ip v4: nil, mac: nil
  # may call further capabilities
end

def ip!
  # called once at the end
end
```

User defined capabilities extend the set of base capabilities by further
mechanisms. They are meant to use the base capabilities to actually generate
actions to be executed on the server.

### base capabilities

The base capabilities `file` and `run` are neccessary to actually generate
actions to be executed on the server.

#### file

```ruby
file "/etc/dhcp/dhcpd.conf", content: "i am in"
```

#### run

```ruby
run "apt-get install -y #{install}",
  check: "dpkg-query -l #{install}"
```

### needs

Jobs following a call of `needs :capability` will get a dependency on
`:capability`.

### trigger

Actions may trigger or may be triggered by other actions. Actions with
`triggered_by`-attributes will only be approved and applied, if the
corresponding trigger has been activated.

```ruby
trigger :reload_dhcp do
  dhcp_server conf: "dns-servers: 8.8.8.8;"
end
triggered_by :reload_dhcp do
  systemctl reload: :dhcpd
end
```

Every job automatically activiates a trigger with the name of the actions
capability, if present.

```ruby
dhcp_server conf: "dns-servers: 8.8.8.8;"
triggered_by :dhcp_server do
  systemctl reload: :dhcpd
end
```

### reading state

Every capability has an automatically generated questionmark suffix version to access jobs called so far.

```ruby
node "example.com" do
  user "alice"
  user "bob", :no_home
  user?    # [["alice", "bob"], [nil, :no_home]]
  user?[0] # ["alice", "bob"] <- grouped by ordered param number
  ip v4: "10.0.0.1", v6: "2000::f0f0:1212"
  ip v4: "192.168.1.55"
  ip?(:v4) # ["10.0.0.1", "192.168.1.55"]
  ip?(:v4) # ["2000::f0f0:1212"]
  ip?(with: :v6) # [{v4: "10.0.0.1", v6: "2000::f0f0:1212"}]
end
```

## nodes

Nodes represent a real server.

```ruby
node "example.com" do
  # defintion
end
```

Further actions:
 - call capabilities
 - include groups
 - add dependencies

## groups

Groups can be used to apply definition to multiple nodes.

```ruby
group :dhcp_clients do
  # definition
end
```

Nodes need to include a groups definition.

```ruby
node "example.com"  do
  group :dhcp_clients
end
```

## expand groups

Groups can be expanded from within other groups or nodes. This way, you can add
definition from one to another node, which is member of the expanded group.
Local variables can be used to pass local state.

```ruby
group :dhcp_clients do
  host = @name
  ip = ip?(:v4).first
  ip = ip?(:mac).first
  group :dhcp_servers do
    dhcp host: host, ip: ip, mac: mac
  end
end
```

# Examples

## dhcp server und clients

`capabilities/ip.rb`:
```ruby
def ip address, mac: nil
end  
```

`capabilities/dhcpd.rb`:
```ruby
def dhcpd!
  hosts = dhcpd?(with: :host).collect{ |host|
    "host #{host[:host]} {
      hardware ethernet #{host[:mac]};
      fixed-address #{host[:ip]};
    }"
  }
  file '/etc/dhcp/dhcpd.conf', content: hosts.join("\n")
end
```

`definitions/dhcp_clients.rb`:
```ruby
group :dhcp_clients do
  host = @name
  ip = ip?.first.first
  mac = ip?(:mac).first
  group :dhcp_servers do
    dhcpd host: host,
      mac: mac,
      ip:  ip
  end
end
```

`definitions/dhcp_servers.rb`:
```ruby
group :dhcp_servers do
end
```

`definitions/router.rb`:
```ruby
node 'router.example.com' do
  group :dhcp_serves
end
```

`definitions/pc.rb`:
```ruby
node 'pc.example.com' do
  ip '10.0.0.2', mac: "22:22:22:22:22:22"
  group :dhcp_clients
end
```

`definitions/notebook.rb`:
```ruby
node 'notebook.example.com' do
  ip '10.0.0.3', mac: "33:33:33:33:33:33"
  group :dhcp_clients
end
```

# TODO

- auto apply via git integration
- display "used infos from" when approving
- https://github.com/jamis/net-ssh-multi, https://github.com/delano/rye
- warn if apt? hasnt been called yet
- dont

`rm ./rbcm-0.0.0.gem; gem build ./rbcm.gemspec; gem install ./rbcm-0.0.0.gem; rbcm ../config/`
