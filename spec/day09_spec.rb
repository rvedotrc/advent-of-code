require 'machine'

RSpec.describe Machine do

  it 'runs a quine' do
    program = [109,1,204,-1,1001,100,1,100,1008,100,16,101,1006,101,0,99]
    m = Machine.new(program.dup)
    m.run
    expect(m.outputs).to eq(program)
  end

  it 'passes example 2' do
    program = [1102,34915192,34915192,7,4,7,99,0]
    m = Machine.new(program)
    m.run
    expect(m.outputs.length).to eq(1)
    expect(m.outputs[0].to_s.length).to eq(16)
  end

  it 'passes example 3' do
    program = [104,1125899906842624,99]
    m = Machine.new(program)
    m.run
    expect(m.outputs).to eq([1125899906842624])
  end

end
