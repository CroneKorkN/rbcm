#!/usr/bin/env ruby

def f &block
  p block.binding.local_variables
end


t = 1

f {}
