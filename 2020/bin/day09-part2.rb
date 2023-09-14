#!/usr/bin/env ruby

require 'set'

def valid?(buffer, n)
  set = Set.new(buffer)

  set.any? do |x|
    y = n - x
    y != x && set.include?(y)
  end
end

def magic_number(all, buffer_length)
  buffer = []

  all.each do |n|
    if buffer.length < buffer_length
      buffer << n
      next
    end

    unless valid?(buffer, n)
      return n
    end

    buffer.shift
    buffer << n
  end

  raise
end

def find_range(all, sums_to)
  q = [[0, 0, 0]]
  seen = Set.new

  while state = q.shift
    next unless seen.add?(state)
    pos0, pos1, sum = state

    if pos1 < all.length
      q.push([pos0, pos1 + 1, sum + all[pos1]])
    end

    if pos1 - pos0 >= 2 && sum == sums_to
      return [pos0, pos1]
    end

    if pos1 > pos0
      q.push([pos0 + 1, pos1, sum - all[pos0]])
    end
  end
end

buffer_length = 25
all = $stdin.each_line.map(&:chomp).map(&:to_i)
magic = magic_number(all, buffer_length)
range = find_range(all, magic)
parts = all[Range.new(range.first, range.last - 1)].sort
puts [parts.min, parts.max].sum
