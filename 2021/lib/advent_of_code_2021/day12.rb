# frozen_string_literal: true

module AdventOfCode2021
  class Day12
    class Part1 < Base
      def calculate(lines)
        require 'set'
        edges = Hash.new { |h, k| h[k] = Set.new }

        lines.each do |line|
          a, b = line.chomp.split('-')
          edges[a].add(b)
          edges[b].add(a)
        end

        solutions = []
        queue = [initial_state]

        until queue.empty?
          state = queue.shift

          if state[:at] == 'end'
            solutions << state[:path]
            next
          end

          edges[state[:at]].each do |to|
            new_state = mutate_state(state, to)
            queue.unshift(new_state) if new_state
          end
        end

        solutions.count
      end

      def initial_state
        { at: 'start', path: ['start'] }
      end

      def mutate_state(state, to)
        return nil unless to == to.upcase || !state[:path].include?(to)

        { at: to, path: state[:path] + [to] }
      end
    end

    class Part2 < Part1
      def initial_state
        { at: 'start', path: ['start'], visited_twice: nil }
      end

      def mutate_state(state, to)
        if to == to.upcase || !state[:path].include?(to)
          return { at: to, path: state[:path] + [to], visited_twice: state[:visited_twice] }
        end

        return nil if to == 'start'
        return nil unless state[:visited_twice].nil?

        { at: to, path: state[:path] + [to], visited_twice: to }
      end
    end
  end
end
