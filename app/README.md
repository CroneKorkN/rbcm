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

# Framework

- class RBCM is initiated
- invokes Node.populate to load the capabilities
- loads the node files
- node object is created for every nodename passed
  - the block passed to the nodes function ist cought via 'Proc.new'
  - Proc (with definitions in it) is saved in an array in the corresponding node
- RBCM.render makes the nodes call the saved definitions
- capability takes the parameters of the definition and generates commands to be run
  on the node
- commands are saved, files generated
- files are pushed to server, file manipulations applied
  - 'file' capability has priority over commands
- commands are executed on server

# TODO
 - add version of capability with '?'-suffix to check for config
 - jobs handle blocks
 - per capability dependencys?
 - files and manipulations as command-instances
   - default files dependency on all capabilities
 - http://tech.tulentsev.com/2012/04/define-module-programmatically/
- run worker, not single jobs, otherwise '?'-suffix versions doesnt work and
  local variables in node-files get lost