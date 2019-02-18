def tag name, &block
  instance_eval &block # <- do it this way
end
