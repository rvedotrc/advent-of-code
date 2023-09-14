# frozen_string_literal: true

require_relative './spec_helper'

describe AdventOfCode2021::Day10 do
  let (:example) {
    <<~'DATA'
      [({(<(())[]>[[{[]{<()<>>
      [(()[<>])]({[<{<<[]>>(
      {([(<{}[<>[]}>{[]{[(<()>
      (((({<>}<{<{<>}{[]{[]{}
      [[<[([]))<([[{}[[()]]]
      [{[{({}]{}}([{[{{{}}([]
      {<[[]]>}<{[{[{[]{()[[[]
      [<(<(<(<{}))><([]([]()
      <{([([[(<>()){}]>(<<{{
      <{([{{}}[<[[[<>{}]]]>[]]
    DATA
  }

  describe AdventOfCode2021::Day10::Part1 do
    it "handles the test data" do
      test(example, 26397)
    end
  end

  describe AdventOfCode2021::Day10::Part2 do
    it "handles the test data" do
      test(example, 288957)
    end
  end
end
