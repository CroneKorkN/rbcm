#!/usr/bin/env ruby

def f &block
  pp block.binding.local_variables
end

a=1
f do 
  puts a
end


class Hash
  def method_missing name, *params, &block
    self[name]
  end
end
v = {ckn: 111}
p v.ckn







