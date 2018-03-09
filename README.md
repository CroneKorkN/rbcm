Ruby Config Management
======================

Usage
-----

`ruby app/rbcm.rb.new`

# UI

- user defines nodes
- node file invokes 'nodes' function
  - the first parameter is an array of node names or search patterns
- also a block is given
  - user can invoke capabilities
  - invoking a capability is called a 'job'

# Framework

- class RBCM is initiated
- invokes Node.populate to load the capabilities
- loads the node files
  - the block passed to the nodes function ist cought via 'Proc.new'
  - Proc (with jobs in it) is saved in an array




# TODO
- load capabilities independently from filename
  - load into isolated context and diff a before/after of the methodlist?
