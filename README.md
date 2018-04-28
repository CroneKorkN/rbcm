Ruby Config Management
======================

# Usage

`ruby ./rbcm.rb`

# HowTo

## capabilities

Nodes are defined by calling capabilities. Capabilities are methods residing in
files in `capabilities/` directory. Each capability may have a second incarnation,
ending with a bang ("cap!"). The bang-version is called once on each node if
the node called the non-bang-version before.
```
def ip v4: nil, mac: nil
  # may call further capabilities
end

def ip!
  # called once at the end
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
definition to other nodes, being in the expanded group. Local variables can be
used to pass local state.
```
group :default do
  host = @name
  ip = ip?(:v4).first
  ip = ip?(:mac).first
  group :dhcp-clients do
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
