#!/usr/bin/env ruby

require 'set'
seen = Set.new

$stdin.each_line do |text|
  n = text.chomp.to_i
  if seen.include?(2020 - n)
    puts n * (2020 - n)
  end
  seen.add(n)
end
