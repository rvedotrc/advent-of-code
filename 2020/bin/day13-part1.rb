#!/usr/bin/env ruby

earliest_time = $stdin.readline.chomp.to_i
buses = $stdin.readline.chomp.split(',').reject { |t| t == 'x' }.map(&:to_i)

p [ earliest_time, buses ]

times = buses.map do |id|
  x = earliest_time / id
  y = earliest_time % id
  p [ x, y, id * x, id * (x+1) ]

  n = (1.0 * earliest_time / id).ceil
  [ id, id * n ]
end

best = times.min_by(&:last)

puts best.first * (best.last - earliest_time)
