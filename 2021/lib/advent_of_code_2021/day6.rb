# frozen_string_literal: true

module AdventOfCode2021
  class Day6
    class Part1 < Base
      def calculate(lines, iterations: 80)
        by_timer = Hash.new { |h, k| h[k] = 0 }
        lines.first.chomp.split(',').map(&:to_i).each do |t|
          by_timer[t] += 1
        end

        iterations.times do
          next_timer = Hash.new { |h, k| h[k] = 0 }

          by_timer.each do |t, count|
            if t == 0
              next_timer[6] += count
              next_timer[8] += count
            else
              next_timer[t - 1] += count
            end
          end

          by_timer = next_timer
        end

        by_timer.values.sum
      end
    end

    class Part2 < Part1
      def calculate(lines)
        super(lines, iterations: 256)
      end
    end
  end
end
