#!/usr/bin/env ruby

require 'set'

seen = Set.new

$stdin.each_line do |text|
  n = text.chomp.to_i

  seen.each do |x|
    y = 2020 - n - x
    if seen.include?(y)
      p [n ,x, y]
      puts n * x * y
    end
  end

  seen.add(n)
end
