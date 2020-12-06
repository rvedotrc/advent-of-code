#!/usr/bin/env ruby

trees = $stdin.each_line.map(&:chomp)

trees.shift
x = 0
hit = 0

while trees.first
  x += 3
  x = x % (trees.first.length)
  hit += 1 if trees.first[x] == '#'
  trees.shift
end

p hit
