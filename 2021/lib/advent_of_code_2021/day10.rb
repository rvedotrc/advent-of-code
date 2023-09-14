# frozen_string_literal: true

module AdventOfCode2021
  class Day10
    MATCHES = {
      '(' => ')',
      '[' => ']',
      '{' => '}',
      '<' => '>',
    }.freeze

    class Part1 < Base
      SCORES = {
        ')' => 3,
        ']' => 57,
        '}' => 1197,
        '>' => 25137,
      }.freeze

      def calculate(lines)
        lines.map { |line| line_score(line) }.sum
      end

      def line_score(line)
        _stack, first_bad_char = parse_line(line)
        return 0 if first_bad_char.nil?
        SCORES[first_bad_char]
      end

      def parse_line(line)
        stack = []

        line.chars.each do |char|
          case char
          when '<', '(', '[', '{'
            stack << char
          when '>', ')', ']', '}'
            raise if stack.empty?

            if char == MATCHES[stack.last]
              stack.pop
              next
            end

            return [stack, char]
          end
        end

        [stack, nil]
      end
    end

    class Part2 < Part1
      SCORES = {
        ')' => 1,
        ']' => 2,
        '}' => 3,
        '>' => 4,
      }.freeze

      def calculate(lines)
        scores = lines.map do |line|
          score_line(line)
        end.compact.sort

        scores[(scores.length - 1) / 2]
      end

      def score_line(line)
        stack, first_bad_char = parse_line(line)
        return if first_bad_char

        score = 0

        stack.reverse_each do |char|
          score = score * 5 + SCORES[MATCHES[char]]
        end

        score
      end
    end
  end
end
