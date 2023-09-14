# frozen_string_literal: true

require_relative './spec_helper'

describe AdventOfCode2021::Day14 do
  let (:example) {
    <<~'DATA'
      NNCB

      CH -> B
      HH -> N
      CB -> H
      NH -> C
      HB -> C
      HC -> B
      HN -> C
      NN -> C
      BH -> H
      NC -> B
      NB -> B
      BN -> B
      BB -> N
      BC -> B
      CC -> N
      CN -> C
    DATA
  }

  describe AdventOfCode2021::Day14::Part1 do
    it "handles the test data" do
      test(example, 1588)
    end
  end

  describe AdventOfCode2021::Day14::Part2 do
    it "handles the test data" do
      test(example, 2188189693529)
    end
  end
end
