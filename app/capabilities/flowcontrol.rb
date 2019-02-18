def in_a_row &block
  instance_eval &block # <- do it this way
end
