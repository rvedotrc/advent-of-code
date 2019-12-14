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

  context 'part 2' do
    def run(program, input, expected_output)
      m = Machine.new(program.dup, inputs: [input])
      m.run
      expect(m.outputs).to eq([expected_output])
    end

    let(:p1) {[3,9,8,9,10,9,4,9,99,-1,8]}
    let(:p2) {[3,9,7,9,10,9,4,9,99,-1,8]}
    let(:p3) {[3,3,1108,-1,8,3,4,3,99]}
    let(:p4) {[3,3,1107,-1,8,3,4,3,99]}

    let(:p5) {[3,12,6,12,15,1,13,14,13,4,13,99,-1,0,1,9]}
    let(:p6) {[3,3,1105,-1,9,1101,0,0,12,4,12,99,1]}

    it 'passes example 1' do
      aggregate_failures do
        run(p1, 7, 0)
        run(p1, 8, 1)
        run(p1, 9, 0)
      end
    end

    it 'passes example 2' do
      aggregate_failures do
        run(p2, 7, 1)
        run(p2, 8, 0)
        run(p2, 9, 0)
      end
    end

    it 'passes example 3' do
      aggregate_failures do
        run(p3, 7, 0)
        run(p3, 8, 1)
        run(p3, 9, 0)
      end
    end

    it 'passes example 4' do
      aggregate_failures do
        run(p4, 7, 1)
        run(p4, 8, 0)
        run(p4, 9, 0)
      end
    end

    it 'passes example 5' do
      aggregate_failures do
        run(p5, -2, 1)
        run(p5, 0, 0)
        run(p5, 4, 1)
      end
    end

    it 'passes example 6' do
      aggregate_failures do
        run(p6, -2, 1)
        run(p6, 0, 0)
        run(p6, 4, 1)
      end
    end

  end

end
