require 'ostruct'
require 'set'

class MazeToGraph

  def initialize(maze)
    maze = maze.gsub(/^\s+/, '')

    rows = maze.lines.map(&:chomp)

    nodes = {}

    rows.each_with_index do |row, y|
      row.chars.each_with_index do |cell, x|
        case cell
        when '#'
        when '.', 'a'..'z', 'A'..'Z', '@'
          nodes[[x, y]] = Node.new([x, y], type: cell)
        else
          raise "Unexpected cell #{cell.inspect}"
        end
      end
    end

    # Find edges
    nodes.values.each do |node|
      [ [0, 1], [1, 0] ].each do |offsets|
        neighbour_position = node.position.zip(offsets).map {|t| t.reduce(&:+) }
        neighbour = nodes[neighbour_position] or next

        edge = Edge.new(node.position, neighbour.position)
        node.edges << edge
        neighbour.edges << edge
      end
    end

    @nodes = nodes.values
  end

  attr_reader :nodes

  def puts_dot
    puts "graph g {"

    position_name = lambda { |position| "n_#{position.first}_#{position.last}" }
    node_name = lambda { |node| position_name.call(node.position) }

    nodes.each do |node|
      puts "  #{node_name.call(node)} [label=\"#{node.type}\"]"
    end

    nodes.map(&:edges).reduce(&:+).uniq.each do |edge|
      positions = edge.positions.map { |pos| position_name.call(pos) }.join(' -- ')
      puts "  #{positions} [ label=\"distance: #{edge.distance}\"]"
    end

    puts "}"
  end

  def reduce!
    while true
      node_to_remove = nodes.find {|node| node.edges.count == 2}
      node_to_remove or break

      old_edges = node_to_remove.edges
      new_edge = Edge.new(
        *old_edges.map(&:positions).reduce(&:+).delete(node_to_remove.position),
        distance: old_edges.map(&:distance).reduce(&:+),
      )

      node_to_remove.edges_to.each do |edge_to|
        to_node = nodes.find {|n| n.position == edge_to.to}
        to_node.edges.delete(edge_to.edge)
        to_node.edges << new_edge
      end

      nodes.delete(node_to_remove)
    end
  end

  class Node
    def initialize(position, type:)
      @position = position
      @edges = []
      @type = type
    end

    attr_reader :position, :edges, :type

    def edges_to
      edges.map do |edge|
        to = (edge.positions - [position]).first

        OpenStruct.new(edge: edge, to: to)
      end
    end
  end

  class Edge
    def initialize(from_position, to_position, distance: 1)
      @positions = Set.new([from_position, to_position])
      @distance = distance
    end

    attr_reader :positions, :distance
  end

end
