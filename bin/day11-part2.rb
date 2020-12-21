#!/usr/bin/env ruby

require 'set'

state = $stdin.each_line.map(&:chomp)

def build_visibility_map(state)
  visible = Hash.new do |hash, key|
    hash[key] = Set.new
  end

  add = ->(x1, y1, x2, y2) do
    visible[[x1, y1]].add([x2, y2])
    visible[[x2, y2]].add([x1, y1])
  end

  state.each_with_index do |line, y|
    line.chars.each_with_index do |char, x|
      # puts "check #{x}, #{y}"
      next if char == '.'

      scan = ->(dx, dy) do
        # puts "Scan #{dx},#{dy} from #{x},#{y}"

        cx = x
        cy = y

        while true
          cx += dx
          cy += dy

          at = (state[cy] || [])[cx]
          break if at.nil?
          next if at == '.'

          add.call(x, y, cx, cy)
          break
        end
      end

      scan.call(1, 0)
      scan.call(1, 1)
      scan.call(0, 1)
      scan.call(-1, 1)
    end
  end

  visible
end

def count_neighbours(state, vmap, y, x)
  vmap[[x, y]].count do |nx, ny|
    state[ny][nx] == '#'
  end
end

def iterate(state, vmap)
  state.each_with_index.map do |line, y|
    line.chars.each_with_index.map do |c, x|
      if c == '.'
        '.'
      else
        neighbours = count_neighbours(state, vmap, y, x)
        # $stderr.puts "#{x},#{y} => #{neighbours}"
        if neighbours == 0
          '#'
        elsif neighbours >= 5
          'L'
        else
          c
        end
      end
    end.join('')
  end
end

vmap = build_visibility_map(state)

step = 0
while true
  puts step
  puts *state
  puts

  new_state = iterate(state, vmap)
  break if new_state == state

  step += 1
  state = new_state
end

puts state.join('').count('#')
