def tag name
  instance_eval &Proc.new # <- do it this way
end
