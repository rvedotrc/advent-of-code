#!/usr/bin/env ruby

seeds = ARGV[0].split(',')
limit = ARGV[1].to_i

ages = Hash.new { |h, k| h[k] = [] }
age = 0
last_n = nil

while true
  n = if seeds.any?
        seeds.shift.to_i
      elsif ages[last_n].length == 1
        0
      else
        ages[last_n][-1] - ages[last_n][-2]
      end

  ages[n] << age
  age += 1
  last_n = n

  break if age == limit
end

puts last_n
