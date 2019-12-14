#!/usr/bin/env ruby

def fuel_for(mass)
  (mass / 3.0).floor - 2
end

def fuel_for_module(mass)
  total = 0

  while true
    fuel = fuel_for(mass)
    break if fuel <= 0
    total += fuel
    mass = fuel
  end

  total
end

if $0 == __FILE__
  masses = $stdin.each_line.map do |t|
    fuel_for_module(t.chomp.to_f)
  end

  puts masses.reduce(&:+)
else
  require 'rspec'
  RSpec.describe do
    it 'calculates fuel_for' do
      expect(fuel_for(12)).to eq(2)
      expect(fuel_for(14)).to eq(2)
      expect(fuel_for(1969)).to eq(654)
      expect(fuel_for(100756)).to eq(33583)
    end

    it 'calculates fuel_for_module' do
      expect(fuel_for_module(14)).to eq(2)
      expect(fuel_for_module(1969)).to eq(966)
      expect(fuel_for_module(100756)).to eq(50346)
    end
  end
end
