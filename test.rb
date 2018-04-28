#!/usr/bin/env ruby

def f &block
  pp block.binding.local_variables
end

a=1
f do 
  puts a
end
