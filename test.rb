#!/usr/bin/env ruby

module M
  def m
    p self
  end
end

class C end
C.define_method :m, &M.instance_method(:m).bind(C)
C.new.m
p M.instance_methods
