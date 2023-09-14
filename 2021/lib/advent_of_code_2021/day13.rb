# frozen_string_literal: true

module AdventOfCode2021
  class Day13
    class Part1 < Base
      def calculate(lines)
        @lines = lines.to_a
        read
        do_folds(1)
        dots.size
      end

      attr_reader :lines, :dots

      def read
        require 'set'
        @dots = Set.new

        while true
          line = lines.shift
          break if line.chomp.empty?

          x, y = line.chomp.split(',').map(&:to_i)
          @dots.add([x, y])
        end
      end

      def do_folds(iterations)
        lines.each do |line|
          if line.match(/^fold along ([xy])=(\d+)$/)
            axis = $1
            where = $2.to_i
            @dots = fold(dots, axis, where)
          else
            raise
          end

          if iterations
            iterations -= 1
            break if iterations == 0
          end
        end
      end

      def fold(dots, axis, where)
        dots.map do |x, y|
          if axis == 'x'
            [where - (where - x).abs, y]
          else
            [x, where - (where - y).abs]
          end
        end.to_set
      end
    end

    class Part2 < Part1
      def calculate(lines)
        @lines = lines.to_a
        read
        do_folds(nil)

        max_x = dots.map(&:first).max
        max_y = dots.map(&:last).max

        (0..max_y).each do |y|
          puts((0..max_x).map { |x| dots.include?([x, y]) ? 'XX' : '  ' }.join)
        end

        nil
      end
    end
  end
end
