# frozen_string_literal: true

require_relative './spec_helper'

describe AdventOfCode2021::Day3 do
  let (:example) {
    <<~'DATA'
      00100
      11110
      10110
      10111
      10101
      01111
      00111
      11100
      10000
      11001
      00010
      01010
    DATA
  }
  describe AdventOfCode2021::Day3::Part1 do
    it "handles the test data" do
      test(example, 198)
    end
  end

  describe AdventOfCode2021::Day3::Part2 do
    it "handles the test data" do
      test(example, 230)
    end
  end
end
