# frozen_string_literal: true

require_relative '../lib/advent_of_code_2021'

RSpec.configure do |config|
  m = Module.new do
    def self.included(_other)
      def test(text, expected)
        actual = described_class.new(text.each_line).answer
        expect(actual).to eq(expected)
      end
    end
  end

  config.include m
end
