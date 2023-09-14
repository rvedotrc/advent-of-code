# frozen_string_literal: true

module AdventOfCode2021
  class Base
    def self.run(fh)
      answer = new(fh.each_line).answer
      puts answer if answer
    end

    def initialize(lines)
      @answer = calculate(lines)
    end

    attr_reader :answer
  end
end
