#!/usr/bin/env ruby

@cache = {}

def find_neighbours(coords)
  @cache[coords] ||= begin
    [-1, 0, 1].map do |dx|
      [-1, 0, 1].map do |dy|
        [-1, 0, 1].map do |dz|
          [-1, 0, 1].map do |dw|
            [coords[0] + dx, coords[1] + dy, coords[2] + dz, coords[3] + dw]
          end
        end
      end
    end.flatten(3) - [coords]
  end
end

def count_neighbours(space, coords)
  find_neighbours(coords).count do |neighbour|
    space.include?(neighbour)
  end
end

def iterate(space)
  new_space = Set.new

  x_range = space.map {|c| c[0]}
  y_range = space.map {|c| c[1]}
  z_range = space.map {|c| c[2]}
  w_range = space.map {|c| c[3]}

  (x_range.min-1 .. x_range.max+1).each do |x|
    (y_range.min-1 .. y_range.max+1).each do |y|
      (z_range.min-1 .. z_range.max+1).each do |z|
        (w_range.min-1 .. w_range.max+1).each do |w|
          coord = [x, y, z, w]
          n = count_neighbours(space, coord)
          # puts "#{coord.inspect} -> #{n}"

          if space.include?(coord)
            if n == 2 || n == 3
              new_space.add(coord)
            end
          else
            if n == 3
              new_space.add(coord)
            end
          end
        end
      end
    end
  end

  new_space
end

require 'set'
space = Set.new

$stdin.each_line.each_with_index do |line, x|
  line.chars.each_with_index do |c, y|
    space.add([x, y, 0, 0]) if c == '#'
  end
end

6.times do
  puts space.size
  space = iterate(space)
end

p space.size
