#!/usr/bin/env ruby

class A
  def initialize
    File.directory?
  end
end

class A::File
end

p A.new
