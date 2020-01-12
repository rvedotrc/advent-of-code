require 'maze_to_graph'

RSpec.describe MazeToGraph do

  it 'parses a maze' do
    maze = <<-MAZE
      #####
      ##.##
      #...#
      ###.#
      ###.#
      #####
    MAZE

    graph = described_class.new(maze)
    expect(graph.nodes.count).to eq(6)
    expect(graph.nodes.map { |node| node.edges.count }).to contain_exactly(1, 1, 3, 2, 2, 1)
  end

  it 'reduces nodes' do
    maze = <<-MAZE
      #####
      ##.##
      #...#
      ###.#
      ###.#
      #####
    MAZE

    graph = described_class.new(maze)
    graph.reduce!
    expect(graph.nodes.count).to eq(4)
    expect(graph.nodes.map { |node| node.edges.count }).to contain_exactly(1, 1, 3, 1)
  end

  it 'calculates distances' do
    maze = <<-MAZE
      #####
      ##.##
      #...#
      ###.#
      ###.#
      #####
    MAZE

    graph = described_class.new(maze)
    graph.reduce!

    corner = graph.nodes.find {|node| node.position == [3, 4]}
    expect(corner.edges.map(&:distance)).to contain_exactly(3)

    junction = graph.nodes.find {|node| node.position == [2, 2]}
    expect(junction.edges.map(&:distance)).to contain_exactly(1, 1, 3)
  end


end
