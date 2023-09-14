# frozen_string_literal: true

require 'set'

module AdventOfCode2021
  class Day15
    class Nodes
      def initialize
        # lookup by node
        @distances = {} # missing (nil) = infinity
        @visited = Set.new

        # unvisited (with a distance), sorted by distance, x, y
        @unvisited_with_distance = []
      end

      def add_distance(node, distance)
        current_distance = @distances[node]

        if current_distance.nil?
          @distances[node] = distance
          new_index = find([distance, *node])
          @unvisited_with_distance.insert(new_index, [distance, *node])
        elsif distance < current_distance
          old_index = find([current_distance, *node])
          @unvisited_with_distance.slice(old_index)

          @distances[node] = distance

          new_index = find([distance, *node])
          @unvisited_with_distance.insert(new_index, [distance, *node])
        end
      end

      def visited?(node)
        @visited.include?(node)
      end

      def mark_visited(node)
        @visited << node

        old_index = find([@distances[node], *node])
        @unvisited_with_distance.slice!(old_index)
      end

      def nearest_unvisited
        @unvisited_with_distance.first[1..-1]
      end

      def distance_to(node)
        @distances[node]
      end

      # Return first position which is >= entry.
      # 0 means entry is either first, or before-first
      # count means entry is > last
      # Note that if empty then 0 and count are the same thing.
      def find(entry)
        arr = @unvisited_with_distance

        x = 0
        y = arr.count

        while x < y
          # x points to an item;
          # y *might* point to an item.
          mid = ((x + y) / 2).floor # x <= mid < y
          # mid points to an item (which might be x)

          item = arr[mid]
          cmp = if item[0] < entry[0]
                  -1
                elsif item[0] > entry[0]
                  +1
                elsif item[1] < entry[1]
                  -1
                elsif item[1] > entry[1]
                  +1
                else
                  item[2] <=> entry[2]
                end

          if cmp > 0
            y = mid
          elsif cmp < 0
            x = mid + 1
          else
            x = y = mid
          end
        end

        x
      end
    end

    class Part1 < Base
      attr_reader :lines, :max_x, :max_y, :nodes

      def calculate(input_lines)
        @lines = input_lines.map(&:chomp).to_a
        @max_x = lines.first.length - 1
        @max_y = lines.length - 1

        @nodes = Nodes.new
        @nodes.add_distance([0, 0], 0)
        current = [0, 0]

        while true
          unvisited_neighbours = unvisited_neighbours_of(*current)

          unvisited_neighbours.each do |neighbour|
            distance = nodes.distance_to(current) + lines[neighbour.last][neighbour.first].to_i
            nodes.add_distance(neighbour, distance)
          end

          nodes.mark_visited(current)
          break if current == [max_x, max_y]

          current = nodes.nearest_unvisited
        end

        nodes.distance_to([max_x, max_y])
      end

      def neighbours_of(x, y)
        [
          ([x - 1, y] if x > 0),
          ([x + 1, y] if x < max_x),
          ([x, y - 1] if y > 0),
          ([x, y + 1] if y < max_y),
        ].compact
      end

      def unvisited_neighbours_of(x, y)
        neighbours_of(x, y).reject { |pos| nodes.visited?(pos) }
      end
    end

    class Part2 < Part1
      def calculate(input_lines)
        input_lines = input_lines.map(&:chomp)

        bigger_grid = (0..4).map do |tile_y|
          input_lines.map do |line|
            (0..4).map do |tile_x|
              rotate(line, tile_x + tile_y)
            end.join
          end
        end.flatten(1)

        super(bigger_grid)
      end

      def rotate(line, n)
        n = n % 9
        old_seq = '123456789'
        new_seq = (old_seq + old_seq)[n .. n+8]
        line.tr(old_seq, new_seq)
      end
    end
  end
end
