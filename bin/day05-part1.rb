#!/usr/bin/env ruby

ids = $stdin.each_line.map do |line|
  code = line.chomp
  Integer(code.tr('FBLR', '0101'), 2)
end

p ids
p ids.max
