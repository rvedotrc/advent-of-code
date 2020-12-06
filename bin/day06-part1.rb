#!/usr/bin/env ruby

puts($stdin.read.split(/\n\n+/).map do |g|
  uniq = g.chars.uniq - ["\n"]
  uniq.count
end.sum)
