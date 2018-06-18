#!/usr/bin/env ruby

class A
  def m
    p self
  end
end

class B
end

B.define_method :m, &A.new.method(:m)
B.new.m2
