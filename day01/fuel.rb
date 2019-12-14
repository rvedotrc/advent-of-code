#!/usr/bin/env ruby

def fuel_for(mass)
  (mass / 3.0).floor - 2
end

raise "nope" unless fuel_for(12) == 2
raise "nope" unless fuel_for(14) == 2
raise "nope" unless fuel_for(1969) == 654
raise "nope" unless fuel_for(100756) == 33583

masses = $stdin.each_line.map do |t|
  (t.chomp.to_f / 3.0).floor - 2
end

puts masses.reduce(&:+)
