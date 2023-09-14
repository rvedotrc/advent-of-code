# frozen_string_literal: true

require_relative './spec_helper'

describe AdventOfCode2021::Day9 do
  let (:example) {
    <<~'DATA'
      2199943210
      3987894921
      9856789892
      8767896789
      9899965678
    DATA
  }

  describe AdventOfCode2021::Day9::Part1 do
    it "handles the test data" do
      test(example, 15)
    end
  end

  describe AdventOfCode2021::Day9::Part2 do
    it "handles the test data" do
      test(example, 1134)
    end
  end
end
