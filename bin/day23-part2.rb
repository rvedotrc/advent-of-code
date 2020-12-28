#!/usr/bin/env ruby

cups = ARGV[0].chars.map(&:to_i)
iterations = ARGV[1].to_i
min = cups.min
max = cups.max
cups = cups.concat((max + 1 .. 1000000).to_a)

require 'set'
seen = Set.new

iterations.times do |n|
  puts n
  # puts "#{n} #{cups.join('')}"
  raise if cups.length != 1E6

  raise unless seen.add?(cups)

  taken = cups[1..3]
  cups = [cups[0]] + cups[4..-1]

  destination = cups[0] - 1

  while true
    if destination < min
      destination = max
    end

    break if cups.include?(destination)

    destination -= 1
  end

  destination_index = cups.index(destination)
  cups = cups.slice(0, destination_index + 1) + taken + cups.slice(destination_index + 1, cups.length)
  cups.push(cups.shift)
end

# puts cups.join('')

index_of_one = cups.index(1)
puts(
  cups[(index_of_one + 1) % cups.length] \
  *
  cups[(index_of_one + 2) % cups.length]
)

