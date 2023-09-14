# frozen_string_literal: true

module AdventOfCode2021
  class Day3
    class Part1 < Base
      def calculate(lines)
        lines = lines.to_a.map(&:chomp)
        ones = [0] * lines.first.length

        lines.each do |line|
          line.chars.each_with_index do |char, index|
            ones[index] += 1 if char == "1"
          end
        end

        halfway = lines.count / 2.0
        gamma = ones.map { |count| count > halfway ? "1" : "0" }.join.to_i(2)
        epsilon = 2 ** (lines.first.length) - 1 - gamma

        gamma * epsilon
      end
    end

    class Part2 < Base
      def calculate(lines)
        lines = lines.to_a.map(&:chomp)

        oxygen = filter(lines, most_common: true)
        co2 = filter(lines, most_common: false)

        oxygen.to_i(2) * co2.to_i(2)
      end

      def filter(lines, most_common:, index: 0)
        ones, zeroes = lines.partition do |line|
          line[index] == "1"
        end

        lines = if most_common
                  zeroes.count > ones.count ? zeroes : ones
                else
                  ones.count < zeroes.count ? ones : zeroes
                end

        return lines[0] if lines.count == 1

        raise if lines.empty?

        index += 1
        raise if index >= lines.first.length

        filter(lines, most_common: most_common, index: index)
      end
    end
  end
end
