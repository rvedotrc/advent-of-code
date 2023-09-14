# frozen_string_literal: true

module AdventOfCode2021
  class Day9
    class Part1 < Base
      def calculate(lines)
        lines = lines.map(&:chomp)

        minima = lines.each_with_index.map do |line, y|
          line.chars.each_with_index.map do |char, x|
            next if x > 0 && char >= line[x - 1]
            next if x < line.length - 1 && char >= line[x + 1]
            next if y > 0 && char >= lines[y - 1][x]
            next if y < lines.length - 1 && char >= lines[y + 1][x]
            char.to_i
          end.compact
        end.flatten(1).compact

        minima.sum + minima.count
      end
    end

    class Part2 < Base
      WALL = ' '
      HOLE = '0'

      attr_reader :lines

      def calculate(lines)
        @lines = lines.map(&:chomp).map { |s| s.tr('[0-8]', HOLE).tr('9', WALL) }

        # render

        pools = []

        while start = find_pool
          pools << explore_pool(start)
          # render
        end

        pools.sort.reverse.take(3).reduce(&:*)
      end

      def render
        puts
        puts *lines
        puts
      end

      def find_pool
        lines.each_with_index do |line, y|
          x = line.index(HOLE)
          return [x, y] if x
        end

        nil
      end

      def explore_pool(start)
        area = 0
        queue = [start]

        until queue.empty?
          x, y = queue.shift
          next if y < 0 || x < 0 || !lines[y] || !lines[y][x]
          next if lines[y][x] == WALL

          area += 1
          lines[y][x] = WALL

          queue.unshift([x + 1, y])
          queue.unshift([x - 1, y])
          queue.unshift([x, y + 1])
          queue.unshift([x, y - 1])
        end

        area
      end
    end
  end
end
