require 'machine'

RSpec.describe Machine do

  it 'inputs and outputs' do
    m = Machine.new([3,0,4,0,99], inputs: [7])
    m.run
    expect(m.outputs).to eq([7])
  end

  it 'supports address mode' do
    m = Machine.new([1,5,6,7,99,123,200,0])
    m.run
    expect(m.memory.last).to eq(123+200)
  end

  it 'supports immediate mode' do
    m = Machine.new([1101,5,6,7,99,123,200,0])
    m.run
    expect(m.memory.last).to eq(5+6)
  end

  it 'supports mixed mode' do
    m = Machine.new([1001,5,6,7,99,123,200,0])
    m.run
    expect(m.memory.last).to eq(123+6)
  end

end
