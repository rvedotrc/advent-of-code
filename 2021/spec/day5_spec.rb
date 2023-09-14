# frozen_string_literal: true

require_relative './spec_helper'

describe AdventOfCode2021::Day5 do
  let (:example) {
    <<~'DATA'
      0,9 -> 5,9
      8,0 -> 0,8
      9,4 -> 3,4
      2,2 -> 2,1
      7,0 -> 7,4
      6,4 -> 2,0
      0,9 -> 2,9
      3,4 -> 1,4
      0,0 -> 8,8
      5,5 -> 8,2
    DATA
  }

  describe AdventOfCode2021::Day5::Part1 do
    it "handles the test data" do
      test(example, 5)
    end
  end

  describe AdventOfCode2021::Day5::Part2 do
    it "handles the test data" do
      test(example, 12)
    end
  end
end
