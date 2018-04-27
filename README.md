Ruby Config Management
======================

# Usage

`ruby ./rbcm.rb`

# UI

- user defines nodes
- node file invokes 'nodes' function
  - the first parameter is an array of node names or search patterns
- also a block is given
  - user can invoke capabilities
  - invoking a capability is called a 'definition'

# TODO

- triggers
- file diff
- command siblings

- auto apply via git integration

`rm ./rbcm-0.0.0.gem; gem build ./rbcm.gemspec; gem install ./rbcm-0.0.0.gem; rbcm ../config/`
