require 'maze_to_graph'
require 'maze_solver'

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
    expect(graph.nodes.map { |node| graph.neighbours_of(node).count }).to contain_exactly(1, 1, 3, 2, 2, 1)
  end

  it 'reduces intermediate nodes' do
    maze = <<-MAZE
      #####
      ##a##
      #b@.#
      ###.#
      ###c#
      #####
    MAZE

    graph = described_class.new(maze)
    graph.reduce_intermediate_nodes!
    expect(graph.nodes.count).to eq(4)
    expect(graph.nodes.map { |node| graph.neighbours_of(node).count }).to contain_exactly(1, 1, 3, 1)
  end

  it 'calculates distances' do
    maze = <<-MAZE
      #####
      ##a##
      #b@.#
      ###.#
      ###c#
      #####
    MAZE

    graph = described_class.new(maze)
    graph.reduce_intermediate_nodes!

    node_c = graph.nodes.find {|node| node.what == 'c'}
    expect(graph.neighbours_of(node_c).map(&:edge).map(&:distance)).to contain_exactly(3)

    expect(graph.neighbours_of(graph.current_node).map(&:edge).map(&:distance)).to contain_exactly(1, 1, 3)
  end

  it 'removes dead ends' do
    maze = <<-MAZE
      #####
      ##.##
      #...#
      ###.#
      #a.b#
      #####
    MAZE

    graph = described_class.new(maze)
    graph.reduce_dead_ends!
    graph.reduce_intermediate_nodes!

    expect(graph.nodes.count).to eq(2)
    expect(graph.edges.count).to eq(1)
  end

  it 'removes junctions' do
    maze = <<-MAZE
      #####
      ##A##
      #B..#
      ###.#
      #a.b#
      #####
    MAZE

    graph = described_class.new(maze)
    graph.reduce_intermediate_nodes!

    expect(graph.nodes.map(&:what)).to contain_exactly('a', 'b', 'A', 'B')
    n = graph.nodes.to_h { |n| [n.position, n] }
    expect(graph.edges.map {|e| [n[e.position_a].what, n[e.position_b].what].sort})
      .to contain_exactly(
            ['A', 'B'],
            ['A', 'b'],
            ['B', 'b'],
            ['a', 'b'],
      )
  end

  describe MazeSolver do
    def best_score(maze)
      graph = MazeToGraph.new(maze)
      solver = MazeSolver.new(graph)
      solver.best_distance
    end

    it "solves example 1" do
      expect(best_score(<<~MAZE)).to eq(8)
        #########
        #b.A.@.a#
        #########
      MAZE
    end

    it "solves example 2" do
      expect(best_score(<<~MAZE)).to eq(86)
        ########################
        #f.D.E.e.C.b.A.@.a.B.c.#
        ######################.#
        #d.....................#
        ########################
      MAZE
    end

    it "solves example 3" do
      expect(best_score(<<~MAZE)).to eq(132)
        ########################
        #...............b.C.D.f#
        #.######################
        #.....@.a.B.c.d.A.e.F.g#
        ########################
      MAZE
    end

    it "solves example 4" do
      expect(best_score(<<~MAZE)).to eq(136)
        #################
        #i.G..c...e..H.p#
        ########.########
        #j.A..b...f..D.o#
        ########@########
        #k.E..a...g..B.n#
        ########.########
        #l.F..d...h..C.m#
        #################
      MAZE
    end

    it "solves example 5" do
      expect(best_score(<<~MAZE)).to eq(81)
        ########################
        #@..............ac.GI.b#
        ###d#e#f################
        ###A#B#C################
        ###g#h#i################
        ########################
      MAZE
    end

  end

end
