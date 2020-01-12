require 'ostruct'
require 'set'
require 'weakref'

class MazeToGraph

  # Graph holds strong refs to its nodes and edges.
  # Nodes and edges hold weak refs to the graph.

  def initialize(maze)
    maze = maze.gsub(/^\s+/, '')

    rows = maze.lines.map(&:chomp)

    @nodes_by_position = {}

    @edges_by_node = Hash.new do |hash, key|
      hash[key] = {}
    end

    rows.each_with_index do |row, y|
      row.chars.each_with_index do |what, x|
        case what
        when '#'
        when '.', 'a'..'z', 'A'..'Z', '@'
          add_node(position: [x, y], what: what)
        else
          raise "Unexpected cell #{what.inspect}"
        end
      end
    end

    # Find edges
    nodes.each do |node|
      [
        [0, 1],
        [1, 0],
      ].each do |offsets|
        neighbour_position = node.position.zip(offsets).map {|t| t.reduce(&:+) }
        neighbour = @nodes_by_position[neighbour_position] or next

        add_edge(from: node, to: neighbour, distance: 1)
      end
    end
  end

  def add_node(position:, what:)
    raise if @nodes_by_position.key?(position)

    @nodes_by_position[position] = Node.new(
      graph: self,
      position: position,
      what: what,
    )
  end

  def add_edge(from:, to:, distance:)
    raise if from == to
    raise if @edges_by_node[from][to]
    raise if @edges_by_node[to][from]

    edge = Edge.new(
      graph: self,
      nodes: Set.new([from, to]),
      distance: distance,
    )

    @edges_by_node[from][to] = edge
    @edges_by_node[to][from] = edge
  end

  def nodes
    @nodes_by_position.values
  end

  def edges_from(from)
    @edges_by_node[from].values
  end

  def each_edge_to(from:, &block)
    @edges_by_node[from].each_entry do |to, edge|
      block.call(edge, to)
    end
  end

  def remove_node(node)
    @nodes_by_position.delete(node.position)
  end

  def remove_edge(edge)
    nodes = edge.nodes
    @edges_by_node[nodes.first].delete(nodes.last)
    @edges_by_node[nodes.last].delete(nodes.first)
  end



  def puts_dot
    puts "graph g {"

    position_name = lambda { |position| "n_#{position.first}_#{position.last}" }
    node_name = lambda { |node| position_name.call(node.position) }

    nodes.each do |node|
      puts "  #{node_name.call(node)} [label=\"#{node.what}\"]"
    end

    edges = @edges_by_node.values.flat_map(&:values).uniq

    edges.each do |edge|
      positions = edge.nodes.map { |node| node_name.call(node) }.join(' -- ')
      puts "  #{positions} [ label=\"distance: #{edge.distance}\"]"
    end

    puts "}"
  end

  def reduce!
    while true
      node_to_remove = nodes.find {|node| node.edges.count == 2}
      node_to_remove or break

      distance = 0
      neighbours = []
      node_to_remove.each_edge_to do |edge, to|
        distance += edge.distance
        neighbours << to
        remove_edge(edge)
      end

      remove_node(node_to_remove)

      add_edge(
        from: neighbours.first,
        to: neighbours.last,
        distance: distance,
      )
    end
  end

  class Node
    include Comparable

    def initialize(graph:, position:, what:)
      @graph = WeakRef.new(graph)
      @position = position
      @what = what
      @key = @position.join('-')
    end

    attr_reader :graph, :position, :what, :key

    def ==(other)
      self.key == other.key
    end

    def hash
      key.hash
    end

    def <=>(other)
      key <=> other.key
    end

    def edges
      graph.edges_from(self)
    end

    def each_edge_to(&block)
      graph.each_edge_to(from: self, &block)
    end
  end

  class Edge
    include Comparable

    def initialize(graph:, nodes:, distance:)
      nodes.count == 2 or raise

      @graph = WeakRef.new(graph)
      @nodes = nodes.sort
      @distance = distance
      @key = @nodes.map(&:key).join(':')
    end

    attr_reader :graph, :nodes, :distance, :key

    def ==(other)
      self.key == other.key
    end

    def hash
      key.hash
    end

    def <=>(other)
      key <=> other.key
    end
  end

end
