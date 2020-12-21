#!/usr/bin/env ruby

memory = {}
mask = nil

$stdin.each_line do |line|
  case line
  when/^mask = (\w+)$/
    mask = $1
  when /^mem\[(\d+)\] = (\d+)$/
    memory[$1.to_i] = [$2.to_i, mask]
  else
    raise "?#{line}"
  end
end

puts(memory.entries.map do |addr, (value, mask)|
  bitmask = Integer(mask.tr('01X', '001'), 2)
  set = Integer(mask.tr('01X', '010'), 2)
  (value & bitmask) | (set & ~bitmask)
end.to_a.sum)
