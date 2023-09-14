# frozen_string_literal: true

require_relative './spec_helper'

describe AdventOfCode2021::Day15 do
  let (:example) {
    <<~'DATA'
      1163751742
      1381373672
      2136511328
      3694931569
      7463417111
      1319128137
      1359912421
      3125421639
      1293138521
      2311944581
    DATA
  }

  describe AdventOfCode2021::Day15::Part1 do
    it "handles the test data" do
      test(example, 40)
    end
  end

  describe AdventOfCode2021::Day15::Part2 do
    it "handles the test data" do
      test(example, 315)
    end
  end
end
