# frozen_string_literal: true

require_relative './spec_helper'

describe AdventOfCode2021::Day1 do
  describe AdventOfCode2021::Day1::Part1 do
    it "handles empty" do
      test("", 0)
    end

    it "handles singleton" do
      test("99\n", 0)
    end

    it "handles a small list" do
      test([1, 1, 3, 3, 4].join("\n"), 2)
    end

    it "handles a small list 2" do
      test([5, 1, 6, 1].join("\n"), 1)
    end
  end

  describe AdventOfCode2021::Day1::Part2 do
    it "handles the example" do
      test([607, 618, 618, 617, 647, 716, 769, 792].join("\n"), 5)
    end
  end
end
