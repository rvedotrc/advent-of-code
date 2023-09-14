#!/usr/bin/env ruby

trees = $stdin.each_line.map(&:chomp)

def count_trees(trees, dx, dy)
  x = 0
  y = 0
  hit = 0

  while y + dy < trees.length
    x = (x + dx) % (trees.first.length)
    y += dy
    hit += 1 if trees[y][x] == '#'
  end

  hit
end

puts [
  count_trees(trees, 1, 1),
  count_trees(trees, 3, 1),
  count_trees(trees, 5, 1),
  count_trees(trees, 7, 1),
  count_trees(trees, 1, 2),
].reduce(&:*)

