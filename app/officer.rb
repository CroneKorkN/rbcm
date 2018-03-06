def run command
  log `sudo #{command}`
end

def log entry
  puts entry
end

def node name
  yield
end

# run every file in ../config/nodesö

# recipe: returns bash to be executed on node
