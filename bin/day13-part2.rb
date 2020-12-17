#!/usr/bin/env ruby

_ = $stdin.readline.chomp.to_i
buses = $stdin.readline.chomp.split(',').each_with_index.reject { |t, i| t == 'x' }.map { |t, i| [t.to_i, i] }

buses.each do |id, i|
  puts "X % #{id} = #{i}"
end

