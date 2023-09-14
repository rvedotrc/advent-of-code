# frozen_string_literal: true

module AdventOfCode2021
  class Day4
    class Part1 < Base
      def calculate(lines)
        lines = lines.to_a

        draws = lines.first.split(/,/)
        grids = lines[2..-1].join.split("\n\n").map do |text|
          text.lines.map { |line| line.strip.split(' ') }
        end

        grids = grids.map { |grid| Grid.new(grid) }
        last_draw = nil

        while grids.none?(&:won?) && !draws.empty?
          draw = draws.shift
          last_draw = draw.to_i
          grids.each { |g| g.fill(draw) }
        end

        winning_grid = grids.find(&:won?)

        winning_grid.score * last_draw
      end
    end

    class Grid
      def initialize(grid)
        @grid = grid
        @tgrid = grid.transpose

        @index = grid.each_with_index.map do |cells, y|
          cells.each_with_index.map do |cell, x|
            [cell, [x,y]]
          end
        end.flatten(1).to_h

        @won = false
      end

      def fill(n)
        x, y = @index[n]
        return if x.nil?

        @grid[y][x] = nil
        @tgrid[x][y] = nil

        @won ||= @grid[y].all?(&:nil?)
        @won ||= @tgrid[x].all?(&:nil?)
      end

      def won?
        @won
      end

      def score
        @grid.flatten.compact.map(&:to_i).sum
      end
    end

    class Part2 < Base
      def calculate(lines)
        lines = lines.to_a

        draws = lines.first.split(/,/)
        grids = lines[2..-1].join.split("\n\n").map do |text|
          text.lines.map { |line| line.strip.split(' ') }
        end

        grids = grids.map { |grid| Grid.new(grid) }
        last_draw = nil
        won = []

        while !grids.empty? && !draws.empty?
          draw = draws.shift
          last_draw = draw.to_i

          grids = grids.reject do |grid|
            grid.fill(draw)
            won << grid if grid.won?
          end
        end

        losing_grid = won.last

        losing_grid.score * last_draw
      end
    end
  end
end
