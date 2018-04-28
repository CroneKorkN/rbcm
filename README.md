Ruby Config Management
======================

# Usage

Navigate into a configuration dir and call rbcm.
`>_ rbcm`

## applying

Applying actually passes three steps: checking, approving and execution.

### check

Rbcm compares the affected files and executes the command-checks. Unneccessary
commands are marked and will be skipped in the approvemnt process.

### aprove

The user approves each action interactively.
 - identical actions on multiple nodes can be approved at once by choosing "o"
 - multiple changes to a file can be approved individually by choosing "i"

# HowTo

Rbcm expects to be calles from within a configuration-directory. There must be
a `capabilities/`- and a `nodes/`-directory

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

User defined apabilities extend the set of base capabilities by further
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
