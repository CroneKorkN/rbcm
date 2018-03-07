load "f.rb"

l = lambda(&method(:f))

l.call
