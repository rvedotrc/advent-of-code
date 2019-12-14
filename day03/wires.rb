#!/usr/bin/env ruby

class Wires
  def initialize
    @cells = {}
  end

  def add_path(colour, path)
    position = [0,0]
    steps = 0

    path.split(/,/).each do |instruction|
      vector = case instruction[0]
               when 'U'
                 [0,+1]
               when 'D'
                 [0,-1]
               when 'R'
                 [+1,0]
               when 'L'
                 [-1,0]
               else
                 raise
               end

      distance = instruction[1..-1].to_i

      distance.times do
        steps += 1
        new_position = position.zip(vector).map {|pairs| pairs.reduce(&:+)}
        cell = (@cells[new_position] ||= {})
        cell[colour] ||= steps
        position = new_position
      end
    end
  end

  def all_intersections
    @cells.entries.map do |position, colours|
      position if colours.count > 1
    end.compact
  end

  def best_intersection
    t = all_intersections.map do |position|
      steps = @cells[position].values.reduce(&:+)
      [ position, steps ]
    end

    t.sort_by(&:last).first.last
  end
end

if $0 == __FILE__
  input = IO.read('input').chomp.split(/,/).map(&:to_i)
  w = Wires.new
  input = $stdin.each_line.to_a
  input.each_with_index do |path, index|
    w.add_path(index, path.chomp)
  end
  puts w.best_intersection
else
  require 'rspec'
  RSpec.describe do
    it 'tests 1' do
      w = Wires.new
      w.add_path(:a, 'R75,D30,R83,U83,L12,D49,R71,U7,L72')
      w.add_path(:b, 'U62,R66,U55,R34,D71,R55,D58,R83')
      expect(w.best_intersection).to eq(610)
    end
    it 'tests 2' do
      w = Wires.new
      w.add_path(:a, 'R98,U47,R26,D63,R33,U87,L62,D20,R33,U53,R51')        
      w.add_path(:b, 'U98,R91,D20,R16,D67,R40,U7,R15,U6,R7')
      expect(w.best_intersection).to eq(410)
    end
  end
end
