#!/usr/bin/env ruby

def f *oargs, **kargs
  p oargs
  p kargs
  p [*oargs, kargs]
end

f "hallo", {ja: "nein"}, ja: "nein"
