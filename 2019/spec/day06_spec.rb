require 'orbits'

RSpec.describe Orbits do

  it 'passes the example' do
    input = <<-TEXT
      COM)B
      B)C
      C)D
      D)E
      E)F
      B)G
      G)H
      D)I
      E)J
      J)K
      K)L
    TEXT
    expect(Orbits.new(input).count).to eq(42)
  end

  it 'passes example part 2' do
    input = <<-TEXT
      COM)B
      B)C
      C)D
      D)E
      E)F
      B)G
      G)H
      D)I
      E)J
      J)K
      K)L
      K)YOU
      I)SAN
    TEXT
    expect(Orbits.new(input).distance('YOU', 'SAN')).to eq(4)
  end

end
