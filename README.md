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
- capability takes the parameters of the definition and generates commands to be
  run on the node
- commands are saved, files generated
- files are pushed to server, file manipulations applied
  - 'file' capability has priority over commands
- commands are executed on server

# TODO

 - jobs handle blocks
 - http://tech.tulentsev.com/2012/04/define-module-programmatically/
- capabilitity stack in command object
- jobs dont cover indirect calls (from within cap)
- optional seperation of metadata collection and capability execution
  - optionally define an "!"-suffix-version of a capability
  - executed ones after all collections are run
  - thus, you can collect metadata with `cap do: something` and process it ones
    via `cap!`-method
  - `cap=` only gets applied to node, if `cap` has been either
  - maybe use '=' instead of '!'
- define dependencies outside of capatability method?

`rm ./rbcm-0.0.0.gem; gem build ./rbcm.gemspec; gem install ./rbcm-0.0.0.gem; rbcm ../config/`
