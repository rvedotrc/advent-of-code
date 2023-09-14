# frozen_string_literal: true

require_relative './spec_helper'

describe AdventOfCode2021::Day13 do
  let (:example) {
    <<~'DATA'
      6,10
      0,14
      9,10
      0,3
      10,4
      4,11
      6,0
      6,12
      4,1
      0,13
      10,12
      3,4
      3,0
      8,4
      1,10
      2,14
      8,10
      9,0

      fold along y=7
      fold along x=5
    DATA
  }

  describe AdventOfCode2021::Day13::Part1 do
    it "handles the test data" do
      test(example, 17)
    end
  end

  describe AdventOfCode2021::Day13::Part2 do
    it "handles the test data" do
      test(example, nil)
    end
  end
end
