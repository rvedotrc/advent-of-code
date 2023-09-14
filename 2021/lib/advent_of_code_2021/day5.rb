# frozen_string_literal: true

module AdventOfCode2021
  class Day5
    class Part1 < Base
      def calculate(lines, allow_diagonals: false)
        grid = Grid.new(allow_diagonals: allow_diagonals)

        lines.each do |line|
          line.match(/^(\S+) -> (\S+)$/) or raise

          from_c, to_c = $1, $2

          from = from_c.split(/,/).map(&:to_i)
          to = to_c.split(/,/).map(&:to_i)
          grid.add_line(from, to)
        end

        grid.count_multis
      end
    end

    class Grid
      def initialize(allow_diagonals:)
        @allow_diagonals = allow_diagonals

        @grid = Hash.new do |h1, k1|
          h1[k1] = Hash.new do |h2, k2|
            h2[k2] = 0
          end
        end
      end

      def add_line(from, to)
        vector = from.zip(to).map { |f, t| t <=> f }
        return if !@allow_diagonals && vector.reduce(&:*) != 0

        while true
          @grid[from[0]][from[1]] += 1
          break if from == to

          from = from.zip(vector).map(&:sum)
        end
      end

      def count_multis
        @grid.values.map(&:values).flatten.count { |n| n > 1 }
      end
    end

    class Part2 < Part1
      def calculate(lines)
        super(lines, allow_diagonals: true)
      end
    end
  end
end
