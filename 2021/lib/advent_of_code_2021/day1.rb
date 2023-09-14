# frozen_string_literal: true

module AdventOfCode2021
  class Day1
    class Part1 < Base
      def calculate(lines)
        depths = lines.map(&:to_i)
        previous = nil
        depths.count do |depth|
          (previous && depth > previous).tap { previous = depth }
        end
      end
    end

    class Part2 < Base
      WINDOW = 3

      def calculate(lines)
        depths = lines.map(&:to_i)
        buffer = []

        depths.count do |depth|
          (buffer.count == WINDOW && depth > buffer.first).tap do
            buffer.shift if buffer.count == WINDOW
            buffer.push(depth)
          end
        end
      end
    end
  end
end
