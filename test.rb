#!/usr/bin/env ruby

module M
  def self.method_missing *params
    p params
  end
  p m
end
