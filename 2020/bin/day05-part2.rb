#!/usr/bin/env ruby

ids = $stdin.each_line.map do |line|
  code = line.chomp
  Integer(code.tr('FBLR', '0101'), 2)
end

last = nil

ids.sort.each do |id|
  if last and id == last + 2
    puts last + 1
  end
  last = id
end


