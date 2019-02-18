def in_a_row
  instance_eval &Proc.new # <- do it this way
end
