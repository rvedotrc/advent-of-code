# frozen_string_literal: true

require_relative './spec_helper'

describe AdventOfCode2021::Day7 do
  let (:example) {
    <<~'DATA'
      16,1,2,0,4,2,7,1,2,14
    DATA
  }

  describe AdventOfCode2021::Day7::Part1 do
    it "handles the test data" do
      test(example, 37)
    end
  end

  describe AdventOfCode2021::Day7::Part2 do
    it "handles the test data" do
      test(example, 168)
    end
  end
end
