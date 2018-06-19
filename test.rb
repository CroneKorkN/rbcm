#!/usr/bin/env ruby

module M
  def m
    p self
  end
end

class C end
c = C.new
c.define_singleton_method :m, &M.instance_method(:m).bind(c)
c.m
p M.instance_methods
