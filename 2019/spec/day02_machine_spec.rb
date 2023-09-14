require 'machine'

RSpec.describe Machine do

  def output_of(memory)
    m = Machine.new(memory)
    m.run
    m.memory
  end

  describe '.output_of' do
    it 'passes example 1' do
      expect(output_of([1,0,0,0,99])).to eq([2,0,0,0,99])
    end
    it 'passes example 2' do
      expect(output_of([2,3,0,3,99])).to eq([2,3,0,6,99])
    end
    it 'passes example 3' do
      expect(output_of([2,4,4,5,99,0])).to eq([2,4,4,5,99,9801])
    end
    it 'passes example 4' do
      expect(output_of([1,1,1,4,99,5,6,0,99])).to eq([30,1,1,4,2,5,6,0,99])
    end
  end

end
