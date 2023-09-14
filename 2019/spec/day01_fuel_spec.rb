require 'fuel'

RSpec.describe Fuel do

  context '.fuel_for' do
    it 'passes example 1' do
      expect(Fuel.fuel_for(12)).to eq(2)
    end
    it 'passes example 2' do
      expect(Fuel.fuel_for(14)).to eq(2)
    end
    it 'passes example 3' do
      expect(Fuel.fuel_for(1969)).to eq(654)
    end
    it 'passes example 4' do
      expect(Fuel.fuel_for(100756)).to eq(33583)
    end
  end

  context '.fuel_for_module' do
    it 'passes example 1' do
      expect(Fuel.fuel_for_module(14)).to eq(2)
    end
    it 'passes example 2' do
      expect(Fuel.fuel_for_module(1969)).to eq(966)
    end
    it 'passes example 3' do
      expect(Fuel.fuel_for_module(100756)).to eq(50346)
    end
  end

end
