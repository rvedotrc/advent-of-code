# frozen_string_literal: true

require_relative './spec_helper'

describe AdventOfCode2021::Day12 do
  let (:example1) {
    <<~'DATA'
      start-A
      start-b
      A-c
      A-b
      b-d
      A-end
      b-end
    DATA
  }

  let (:example2) {
    <<~'DATA'
      dc-end
      HN-start
      start-kj
      dc-start
      dc-HN
      LN-dc
      HN-end
      kj-sa
      kj-HN
      kj-dc
    DATA
  }

  let (:example3) {
    <<~'DATA'
      fs-end
      he-DX
      fs-he
      start-DX
      pj-DX
      end-zg
      zg-sl
      zg-pj
      pj-he
      RW-he
      fs-DX
      pj-RW
      zg-RW
      start-pj
      he-WI
      zg-he
      pj-fs
      start-RW
    DATA
  }

  describe AdventOfCode2021::Day12::Part1 do
    it "handles the test data 1" do
      test(example1, 10)
    end

    it "handles the test data 2" do
      test(example2, 19)
    end

    it "handles the test data 3" do
      test(example3, 226)
    end
  end

  describe AdventOfCode2021::Day12::Part2 do
    it "handles the test data 1" do
      test(example1, 36)
    end

    it "handles the test data 2" do
      test(example2, 103)
    end

    it "handles the test data 3" do
      test(example3, 3509)
    end
  end
end
