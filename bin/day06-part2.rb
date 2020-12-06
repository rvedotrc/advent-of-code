#!/usr/bin/env ruby

puts($stdin.read.split(/\n\n+/).map do |g|
  all = g.lines.map(&:chomp).map(&:chars).reduce(&:&)
  all.count
end.sum)
