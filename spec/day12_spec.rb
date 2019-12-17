require 'n_body_universe'

RSpec.describe NBodyUniverse do

  it 'passes example 1' do
    universe = NBodyUniverse.new
    universe.add_body([-1, 0, 2])
    universe.add_body([2, -10, -7])
    universe.add_body([4, -8, 8])
    universe.add_body([3, 5, -1])

    10.times { universe.step }

    expect(universe.bodies.map(&:position)).to eq([
      [2, 1, -3],
      [1, -8, 0],
      [3, -6, 1],
      [2, 0, 4],
    ])

    expect(universe.bodies.map(&:velocity)).to eq([
      [-3, -2, 1],
      [-1, 1, 3],
      [3, 2, -3],
      [1, -1, -1],
    ])

    expect(universe.bodies.map(&:energy)).to eq([
      36,
      45,
      80,
      18,
    ])
  end

  it 'calculates cycle_time' do
    universe = NBodyUniverse.new
    universe.add_body([-1, 0, 2])
    universe.add_body([2, -10, -7])
    universe.add_body([4, -8, 8])
    universe.add_body([3, 5, -1])
    expect(universe.cycle_time).to eq(2772)
  end

  it 'calculates fast_cycle_time' do
    universe = NBodyUniverse.new
    universe.add_body([-1, 0, 2])
    universe.add_body([2, -10, -7])
    universe.add_body([4, -8, 8])
    universe.add_body([3, 5, -1])
    expect(universe.fast_cycle_time).to eq(2772)
  end

  it 'calculates fast_cycle_time (example 2)' do
    universe = NBodyUniverse.new
    universe.add_body([-8, -10, 0])
    universe.add_body([5, 5, 10])
    universe.add_body([2, -7, 3])
    universe.add_body([9, -8, -3])
    expect(universe.fast_cycle_time).to eq(4686774924)
  end

end
