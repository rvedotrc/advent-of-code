# frozen_string_literal: true

module AdventOfCode2021
  class Day8
    DIGITS = [
      'abcefg', # 0
      'cf', # 1
      'acdeg', # 2
      'acdfg', # 3
      'bcdf', # 4
      'abdfg', # 5
      'abdefg', # 6
      'acf', # 7
      'abcdefg', # 8
      'abcdfg', # 9
    ].freeze

    FREQUENCIES = ('a'..'g').map do |char|
      [char, DIGITS.join.count(char)]
    end.to_h

    class Part1 < Base
      def calculate(lines)
        lines.map do |line|
          line.split('|')[1].strip.split(' ').count do |segments|
            l = segments.length
            l == DIGITS[1].length || l == DIGITS[4].length || l == DIGITS[7].length || l == DIGITS[8].length
          end
        end.flatten.sum
      end
    end

    class Part2 < Base
      def calculate(lines)
        lines.map do |line|
          all, readout = line.split(' | ')
          all = all.split(' ').map { |s| s.chars.sort.join }
          readout = readout.split(' ').map { |s| s.chars.sort.join }

          # frequencies:
          # {"a"=>8, "b"=>**6**, "c"=>8, "d"=>7, "e"=>**4**, "f"=>**9**, "g"=>7}
          # b, e, f: unique
          # a/c: 8
          # d/g: 7

          frequencies = all.join.chars.group_by(&:itself).transform_values(&:length)
          freq_inverted = frequencies.invert
          f_b = freq_inverted[6]
          f_e = freq_inverted[4]
          f_f = freq_inverted[9]
          f_a_c = frequencies.keys.select { |k| frequencies[k] == 8 }
          f_d_g = frequencies.keys.select { |k| frequencies[k] == 7 }

          one = all.find { |s| s.length == 2 }
          f_c = one.chars & f_a_c
          f_a = f_a_c - f_c

          four = all.find { |s| s.length == 4 }
          f_d = four.chars & f_d_g
          f_g = f_d_g - f_d

          rewire = [f_a, f_b, f_c, f_d, f_e, f_f, f_g].join

          rewired_readout = readout.map { |s| s.tr(rewire, 'abcdefg').chars.sort.join }

          rewired_readout.map { |seq| DIGITS.index(seq) }.join.to_i
        end.sum
      end
    end
  end
end
