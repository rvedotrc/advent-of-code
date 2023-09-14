# frozen_string_literal: true

require_relative './spec_helper'

describe AdventOfCode2021::Day6 do
  let (:example) {
    <<~'DATA'
      3,4,3,1,2
    DATA
  }

  describe AdventOfCode2021::Day6::Part1 do
    it "handles the test data" do
      test(example, 5934)
    end
  end

  describe AdventOfCode2021::Day6::Part2 do
    it "handles the test data" do
      test(example, 26984457539)
    end
  end
end
