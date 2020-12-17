#!/usr/bin/env ruby

state = $stdin.each_line.map(&:chomp)

def count_neighbours(state, y, x)
  [-1, 0, 1].map do |dy|
    [-1, 0, 1].map do |dx|
      if dx == 0 && dy == 0
        0
      else
        ax = x + dx
        ay = y + dy
        if ax >= 0 && ay >= 0
          c = state[ay]&.[](ax)
          # $stderr.puts "#{y}/#{ay},#{x}/#{ax} => #{c.inspect}"
          (c == '#') ? 1 : 0
        else
          0
        end
      end
    end.sum
  end.sum
end

def iterate(state)
  state.each_with_index.map do |line, y|
    line.chars.each_with_index.map do |c, x|
      if c == '.'
        '.'
      else
        neighbours = count_neighbours(state, y, x)
        # $stderr.puts "#{x},#{y} => #{neighbours}"
        if neighbours == 0
          '#'
        elsif neighbours >= 4
          'L'
        else
          c
        end
      end
    end.join('')
  end
end

step = 0
while true
  puts step
  puts *state
  puts

  new_state = iterate(state)
  break if new_state == state

  step += 1
  state = new_state
end

puts state.join('').count('#')
