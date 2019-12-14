#!/usr/bin/env ruby

def fuel_for(mass)
  (mass / 3.0).floor - 2
end

if $0 == __FILE__
  masses = $stdin.each_line.map do |t|
    fuel_for(t.chomp.to_f)
  end

  puts masses.reduce(&:+)
else
  require 'rspec'
  RSpec.describe do
    it 'works' do
      expect(fuel_for(12)).to eq(2)
      expect(fuel_for(14)).to eq(2)
      expect(fuel_for(1969)).to eq(654)
      expect(fuel_for(100756)).to eq(33583)
    end
  end
end
