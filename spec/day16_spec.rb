require 'fft_algorithm'

RSpec.describe FFTAlgorithm do

  it 'passes example 1' do
    fft = described_class.new('12345678')
    expect(fft.next).to eq('48226158')
    expect(fft.next).to eq('34040438')
    expect(fft.next).to eq('03415518')
    expect(fft.next).to eq('01029498')
  end

  it 'passes example 2' do
    fft = described_class.new('80871224585914546619083218645595')
    expect(fft.next(100)).to start_with('24176176')
  end

  it 'passes example 3' do
    fft = described_class.new('19617804207202209144916044189917')
    expect(fft.next(100)).to start_with('73745418')
  end

  it 'passes example 4' do
    fft = described_class.new('69317163492948606335995924319873')
    expect(fft.next(100)).to start_with('52432133')
  end

end
