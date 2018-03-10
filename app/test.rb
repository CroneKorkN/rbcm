def f
  p "f"
end

from = :f

to = :g

define_method to, &send(:method, f)

g
