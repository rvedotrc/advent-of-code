#!/usr/bin/env ruby

class Machine
  def self.output_of(input, position = 0)
    if position < 0 or position >= input.length
      raise 'bad position'
    end

    case input[position]
    when 1
      l_pos, r_pos, o_pos = [1,2,3].map do |i|
        raise 'bad position' if position+i >= input.length
        value = input[position+i]
        raise 'bad position' if value >= input.length
        value
      end

      output = input.dup
      output[o_pos] = output[l_pos] + output[r_pos]
      output_of(output, position+4)
    when 2
      l_pos, r_pos, o_pos = [1,2,3].map do |i|
        raise 'bad position' if position+i >= input.length
        value = input[position+i]
        raise 'bad position' if value >= input.length
        value
      end

      output = input.dup
      output[o_pos] = output[l_pos] * output[r_pos]
      output_of(output, position+4)
    when 99
      input
    else
      raise 'unexpected opcode'
    end
  end
end

if $0 == __FILE__
  input = IO.read('input').chomp.split(/,/).map(&:to_i)
  input[1] = 12
  input[2] = 2
  final_state = Machine.output_of(input)
  puts final_state.first
else
  require 'rspec'
  RSpec.describe do
    it 'tests 1' do
      expect(Machine.output_of([1,0,0,0,99])).to eq([2,0,0,0,99])
    end
    it 'tests 2' do
      expect(Machine.output_of([2,3,0,3,99])).to eq([2,3,0,6,99])
    end
    it 'tests 3' do
      expect(Machine.output_of([2,4,4,5,99,0])).to eq([2,4,4,5,99,9801])
    end
    it 'tests 4' do
      expect(Machine.output_of([1,1,1,4,99,5,6,0,99])).to eq([30,1,1,4,2,5,6,0,99])
    end
  end
end
