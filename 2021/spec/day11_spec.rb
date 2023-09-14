# frozen_string_literal: true

require_relative './spec_helper'

describe AdventOfCode2021::Day11 do
  let (:example) {
    <<~'DATA'
      5483143223
      2745854711
      5264556173
      6141336146
      6357385478
      4167524645
      2176841721
      6882881134
      4846848554
      5283751526
    DATA
  }

  describe AdventOfCode2021::Day11::Part1 do
    it "handles the test data" do
      test(example, 1656)
    end
  end

  describe AdventOfCode2021::Day11::Part2 do
    it "handles the test data" do
      test(example, 195)
    end
  end
end
