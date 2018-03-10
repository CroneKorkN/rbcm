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
  - invoking a capability is called a 'job'

# Framework

- class RBCM is initiated
- invokes Node.populate to load the capabilities
- loads the node files
- node object is created for every nodename passed
  - the block passed to the nodes function ist cought via 'Proc.new'
  - Proc (with jobs in it) is saved in an array in the corresponding node
- RBCM.apply makes the nodes call the saved jobs
- capability takes the parameters of the job and generates commands to be run
  on the node
- commands are saved, files generated
- files are pushed to server, file manipulations applied
  - 'file' capability has priority over commands
- commands are executed on server

# TODO

- metadata ccessible
  - create wrapper method for each capability
  - define cap with prefix '__real__'
  - before actually running real_cap, the wrapper ist called
  - wrapper saves capname and params
  - after collecting all cap params, real_caps are invokes
  - now every job is able to access all jobs configs
  - how to handle multiple invokations?
