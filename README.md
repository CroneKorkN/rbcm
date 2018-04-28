Ruby Config Management
======================

Navigate into a configuration dir and call rbcm.
`>_ rbcm`

## applying

Applying actually passes three steps: checking, approving and execution.

### check

Rbcm compares the affected files and executes the command-checks. Unneccessary
commands are marked and will be skipped in the approvemnt process.

### approve

The user approves each action interactively.
 - identical actions on multiple nodes can be approved at once by choosing "o"
 - multiple changes to a file can be approved individually by choosing "i"

### execute

All approved actions are being executed.

# Documentation

Rbcm expects to be calles from within a configuration-directory. There must be
a `capabilities/`- and a `nodes/`-directory

## capabilities

Nodes are defined by calling capabilities. Capabilities are methods residing in
files in `capabilities/` directory. Each capability may have a second
incarnation with a bang suffix ("cap!"). The bang version is called once on each
node if the node called the non-bang-version before.
```
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

The two built-in base capabilities `file` and `run` are neccessary to
actually generate actions to be executed on the server.

### file

```
file "/etc/dhcp/dhcpd.conf", content: "i am in"
```

### run

```
run "apt-get install -y #{install}",
  check: "dpkg-query -l #{install}"
```
### reading state

Every capability has a questionmark suffix version to access jobs called so far.
```
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

Nodes represent a real server; they reside in the `nodes/`-directory.
```
node :example.com do
  # defintion
end
```
Further actions:
 - call capabilities
 - include groups
 - add dependencies

## groups

Groups can be used to apply definition to multiple nodes. They also reside in
the `nodes/`-directory.
```
group :dhcp-clients do
  # definition
end
```
Nodes need to include a groups definition.
```
node :example.com do
  group :dhcp-clients
end
```

## expand groups

Groups can be expanded from within other groups or nodes. This way, you can add
definition from one to another node, which is member of the expanded group.
Local variables can be used to pass local state.
```
group :dhcp-clients do
  host = @name
  ip = ip?(:v4).first
  ip = ip?(:mac).first
  group :dhcp-servers do
    dhcp host: host, ip: ip, mac: mac
  end
end
```

# TODO

- triggers
- file diff
- command siblings

- auto apply via git integration

`rm ./rbcm-0.0.0.gem; gem build ./rbcm.gemspec; gem install ./rbcm-0.0.0.gem; rbcm ../config/`
