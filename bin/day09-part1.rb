#!/usr/bin/env ruby

require 'set'

def valid?(buffer, n)
  set = Set.new(buffer)

  set.any? do |x|
    y = n - x
    y != x && set.include?(y)
  end
end

buffer_length = 25
buffer = []

$stdin.each_line do |line|
  n = line.chomp.to_i

  if buffer.length < buffer_length
    buffer << n
    next
  end

  unless valid?(buffer, n)
    puts n
    exit
  end

  buffer.shift
  buffer << n
end
