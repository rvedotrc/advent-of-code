# frozen_string_literal: true

require_relative './spec_helper'

describe AdventOfCode2021::Day2 do
  let(:example) {
    <<~'DATA'
      forward 5
      down 5
      forward 8
      up 3
      down 8
      forward 2
    DATA
  }

  describe AdventOfCode2021::Day2::Part1 do
    it "handles the test data" do
      test(example, 150)
    end
  end

  describe AdventOfCode2021::Day2::Part2 do
    it "handles the test data" do
      test(example, 900)
    end
  end
end
