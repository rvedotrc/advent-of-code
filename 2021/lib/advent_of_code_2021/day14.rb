# frozen_string_literal: true

module AdventOfCode2021
  class Day14
    class Part1 < Base
      def calculate(lines)
        template, rules = parse(lines)

        pair_counts = Hash.new { |h, k| h[k] = 0 }

        template.chars.each_cons(2) do |pair|
          pair_counts[pair] += 1
        end

        iterations.times do
          pair_counts = mutate(pair_counts, rules)
        end

        letter_counts = count_letters(pair_counts, template)

        min, max = letter_counts.values.minmax
        max - min
      end

      def iterations
        10
      end

      def parse(lines)
        lines = lines.to_a
        template = lines.shift.chomp
        lines.shift

        rules = lines.map do |line|
          [line[0..1], line[-2]]
        end.to_h

        [template, rules]
      end

      def mutate(pair_counts, rules)
        output = Hash.new { |h, k| h[k] = 0 }

        pair_counts.each do |(x, z), count|
          y = rules[x + z]
          output[[x, y]] += count
          output[[y, z]] += count
        end

        output
      end

      def count_letters(pair_counts, template)
        counts = Hash.new { |h, k| h[k] = 0 }

        pair_counts.each do |pair, v|
          counts[pair.first] += v
        end

        counts[template.chars.last] += 1

        counts
      end
    end

    class Part2 < Part1
      def iterations
        40
      end
    end
  end
end
