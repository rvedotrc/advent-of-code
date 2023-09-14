require 'asteroid_map'

RSpec.describe AsteroidMap do

  def test(grid:, best_position:, best_count:)
    grid = grid.gsub(/^\s+/, '')
    map = AsteroidMap.new(grid.lines.map(&:chomp))
    best = map.best_position
    expect(best.position).to eq(best_position)
    expect(best.count).to eq(best_count)
  end

  it 'passes example 1' do
    grid = <<-EOF
      ......#.#.
      #..#.#....
      ..#######.
      .#.#.###..
      .#..#.....
      ..#....#.#
      #..#....#.
      .##.#..###
      ##...#..#.
      .#....####
    EOF
    test(grid: grid, best_position: [5,8], best_count: 33)
  end

  it 'passes example 2' do
    grid = <<-EOF
    #.#...#.#.
    .###....#.
    .#....#...
    ##.#.#.#.#
    ....#.#.#.
    .##..###.#
    ..#...##..
    ..##....##
    ......#...
    .####.###.
    EOF
    test(grid: grid, best_position: [1,2], best_count: 35)
  end

  it 'passes example 3' do
    grid = <<-EOF
      .#..#..###
      ####.###.#
      ....###.#.
      ..###.##.#
      ##.##.#.#.
      ....###..#
      ..#.#..#.#
      #..#.#.###
      .##...##.#
      .....#.#..
    EOF
    test(grid: grid, best_position: [6,3], best_count: 41)
  end

  it 'passes example 4' do
    grid = <<-EOF
      .#..##.###...#######
      ##.############..##.
      .#.######.########.#
      .###.#######.####.#.
      #####.##.#.##.###.##
      ..#####..#.#########
      ####################
      #.####....###.#.#.##
      ##.#################
      #####.##.###..####..
      ..######..##.#######
      ####.##.####...##..#
      .#####..#.######.###
      ##...#.##########...
      #.##########.#######
      .####.#.###.###.#.##
      ....##.##.###..#####
      .#.#.###########.###
      #.#.#.#####.####.###
      ###.##.####.##.#..##
    EOF
    test(grid: grid, best_position: [11,13], best_count: 210)
  end

  it 'passes the sweep test' do
    grid = <<-EOF
      .#..##.###...#######
      ##.############..##.
      .#.######.########.#
      .###.#######.####.#.
      #####.##.#.##.###.##
      ..#####..#.#########
      ####################
      #.####....###.#.#.##
      ##.#################
      #####.##.###..####..
      ..######..##.#######
      ####.##.####...##..#
      .#####..#.######.###
      ##...#.##########...
      #.##########.#######
      .####.#.###.###.#.##
      ....##.##.###..#####
      .#.#.###########.###
      #.#.#.#####.####.###
      ###.##.####.##.#..##
    EOF
    grid = grid.gsub(/^\s+/, '')
    map = AsteroidMap.new(grid.lines.map(&:chomp))
    sweep = map.sweep_from([11,13])

    expect(sweep.count).to eq(299)
    sweep.unshift(nil)
    expect(sweep[1]).to eq([11,12])
    expect(sweep[2]).to eq([12,1])
    expect(sweep[3]).to eq([12,2])
    expect(sweep[10]).to eq([12,8])
    expect(sweep[20]).to eq([16,0])
    expect(sweep[50]).to eq([16,9])
    expect(sweep[100]).to eq([10,16])
    expect(sweep[199]).to eq([9,6])
    expect(sweep[200]).to eq([8,2])
    expect(sweep[201]).to eq([10,9])
    expect(sweep[299]).to eq([11,1])
  end

end
