# frozen_string_literal: true

module AdventOfCode2021
  class Day7
    class Part1 < Base
      def calculate(lines)
        positions = lines.first.chomp.split(',').map(&:to_i)

        brute_force = (positions.min..positions.max).map do |pos|
          [pos, positions.map { |x| (x - pos).abs }.sum]
        end.sort_by(&:last)

        brute_force.first.last
      end
    end

    class Part2 < Base
      def calculate(lines)
        positions = lines.first.chomp.split(',').map(&:to_i)

        brute_force = (positions.min..positions.max).map do |pos|
          [pos, positions.map { |x| n = (x - pos).abs; n * (n+1) / 2 }.sum]
        end.sort_by(&:last)

        brute_force.first.last
      end
    end
  end
end
