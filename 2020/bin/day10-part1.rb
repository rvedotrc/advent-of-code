#!/usr/bin/env ruby

adapters = $stdin.each_line.map(&:chomp).map(&:to_i).sort

jolts = [0, *adapters, adapters.last + 3]

map = jolts.each_with_index.map {|j, i|
  jolts[i + 1] - j if i + 1 < jolts.length
}.compact.group_by(&:itself).map {|k, v| [k, v.length]}.to_h

p map
puts map[1] * map[3]
