# frozen_string_literal: true

module AdventOfCode2021
  class Day11
    class Part1 < Base
      def calculate(lines)
        @grid = lines.map { |line| line.chomp.chars.map(&:to_i) }
        @flashes = 0
        100.times { tick }
        flashes
      end

      attr_reader :grid
      attr_accessor :flashes

      def tick
        # show

        grid.each do |row|
          row.each_with_index do |n, x|
            row[x] = n + 1
          end
        end

        require 'set'
        has_flashed = Set.new

        while true
          any_flashed = false

          grid.each_with_index do |row, y|
            row.each_with_index do |n, x|
              if n > 9 && !has_flashed.include?([x, y])
                has_flashed.add([x, y])
                any_flashed = true

                # bump neighbours
                [y - 1, y, y + 1].each do |neighbour_y|
                  [x - 1, x, x + 1].each do |neighbour_x|
                    # Doesn't matter that we do self as well
                    if neighbour_x >= 0 && neighbour_y >= 0 && neighbour_x <= 9 && neighbour_y <= 9
                      grid[neighbour_y][neighbour_x] += 1
                    end
                  end
                end
              end
            end
          end

          break unless any_flashed
        end

        @flashes = @flashes + has_flashed.size

        has_flashed.each do |(x, y)|
          grid[y][x] = 0
        end

        has_flashed.size
      end

      def show
        puts *grid.map(&:join)
        puts
      end
    end

    class Part2 < Part1
      def calculate(lines)
        @grid = lines.map { |line| line.chomp.chars.map(&:to_i) }
        @flashes = 0

        step = 0

        while true
          step += 1
          break if tick == 100
        end

        step
      end
    end
  end
end
