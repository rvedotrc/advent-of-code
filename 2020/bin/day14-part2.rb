#!/usr/bin/env ruby

def expand_address(addr, mask)
  x_index = mask.index('X')

  if x_index
    simpler_mask = mask.dup
    simpler_mask[x_index] = '0'

    power = mask.length - 1 - x_index

    # puts "simplify #{mask} -> #{simpler_mask} #{power}"
    [0, 1].flat_map do |bit|
      new_addr = addr & ~(1 << power) | (bit << power)
      # puts "simplify #{mask} -> #{simpler_mask} #{power} #{bit} #{addr} -> #{new_addr}"
      expand_address(new_addr, simpler_mask)
    end
  else
    # puts "? #{addr},#{mask}"
    [
      addr | (~0 & Integer(mask, 2))
    ]
  end
end

memory = {}
mask = nil

$stdin.each_line do |line|
  case line
  when/^mask = (\w+)$/
    mask = $1
  when /^mem\[(\d+)\] = (\d+)$/
    expand_address($1.to_i, mask).each do |a|
      memory[a] = $2.to_i
    end
  else
    raise "?#{line}"
  end
end

puts memory.values.sum
