require 'ostruct'
require 'set'

class MazeToGraph

  Node = Data.define(:position, :what)
  Edge = Data.define(:node_a, :node_b, :distance)
  Neighbour = Data.define(:edge, :node)

  def initialize(maze)
    maze = maze.gsub(/^\s+/, '')

    rows = maze.lines.map(&:chomp)

    @nodes_by_position = {}
    @current_node = nil

    @edges_by_position = Hash.new do |hash, key|
      hash[key] = []
    end

    rows.each_with_index do |row, y|
      row.chars.each_with_index do |what, x|
        case what
        when '#'
        when '.', 'a'..'z', 'A'..'Z', '@'
          add_node(position: "#{x}_#{y}", what: what)
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
        neighbour_position = node.position.split('_').map(&:to_i).zip(offsets).map {|t| t.reduce(&:+) }.join('_')
        neighbour = @nodes_by_position[neighbour_position] or next

        add_edge(node_a: node, node_b: neighbour, distance: 1)
      end
    end
  end

  def add_node(position:, what:)
    puts "add node #{position} #{what}"
    raise if @nodes_by_position.key?(position)

    new_node = Node.new(position: position, what: what)

    @nodes_by_position[position] = new_node
    @current_node = new_node if what == '@'
  end

  def remove_node(node)
    puts "remove node #{node}"
    @nodes_by_position.delete(node.position) or raise
    @current_node = nil if node.what == '@'
  end

  def add_edge(node_a:, node_b:, distance:)
    puts "add edge #{node_a} #{node_b} #{distance}"
    return if node_a == node_b

    node_a, node_b = node_b, node_a if node_a.position > node_b.position

    existing_edge = @edges_by_position[node_a.position].find { |e| e.node_b.position == node_b.position }

    if existing_edge
      return if existing_edge.distance <= distance

      @edges_by_position[node_a.position].delete(existing_edge)
      @edges_by_position[node_b.position].delete(existing_edge)
    end

    edge = Edge.new(node_a:, node_b:, distance:)
    @edges_by_position[node_a.position] << edge
    @edges_by_position[node_b.position] << edge
  end

  def remove_edge(edge)
    puts "remove edge #{edge}"

    [:node_a, :node_b].each do |ab|
      position = edge.public_send(ab).position
      edges = @edges_by_position[position]

      index = edges.index(edge)
      index >= 0 or raise "Edge #{edge} not found in index at #{edge.node_a.position}"

      edges.delete_at(index)
      @edges_by_position.delete(position) if edges.empty?
    end
  end

  def nodes
    @nodes_by_position.values
  end

  def edges
    @edges_by_position.values.flatten(1).uniq
  end

  attr_reader :current_node

  def puts_dot
    puts "graph g {"

    node_name = lambda { |node| "n_#{node.position}" }

    nodes.each do |node|
      puts "  #{node_name.call(node)} [label=\"#{node.what}\"]"
    end

    edges.each do |edge|
      positions = [edge.node_a, edge.node_b].map { |node| node_name.call(node) }.join(' -- ')
      puts "  #{positions} [ label=\"#{edge.distance}\"]"
    end

    puts "}"
  end

  def reduce!
    while true
      break if !reduce_intermediate_nodes! && !reduce_dead_ends!
    end
  end

  def reduce_dead_ends!
    changed = false

    while true
      node_to_remove = nodes.find do |node|
        node.what == '.' and count_neighbours(node) == 1
      end

      node_to_remove or break

      puts "remove dead end #{node_to_remove}"

      # Should only be 1 neighbour
      neighbours_of(node_to_remove).each do |neighbour|
        remove_edge(neighbour.edge)
      end

      remove_node(node_to_remove)

      changed = true
    end

    changed
  end

  def reduce_intermediate_nodes!
    changed = false

    while true
      node_to_remove = nodes.find do |node|
        node.what == '.' and count_neighbours(node) == 2
      end

      node_to_remove ||= nodes.find do |node|
        node.what == '.' and count_neighbours(node) > 2
      end

      node_to_remove or break

      puts "remove intermediate #{node_to_remove} with #{count_neighbours(node_to_remove)} neighbours"
      neighbours = neighbours_of(node_to_remove).to_a

      # First remove the node and its edges
      neighbours.map(&:edge).each { |edge| remove_edge(edge) }
      remove_node(node_to_remove)

      # Then add an edge between all combinations of neighbours
      neighbours.combination(2).each do |a, b|
        add_edge(
          node_a: a.node,
          node_b: b.node,
          distance: a.edge.distance + b.edge.distance,
        )
      end

      changed = true
    end

    changed
  end

  def count_neighbours(node)
    @edges_by_position[node.position].count
  end

  def neighbours_of(node)
    return enum_for(:neighbours_of, node) unless block_given?

    # puts "neighbours of #{node}"
    @edges_by_position[node.position].each do |edge|
      other_node = (edge.node_a == node ? edge.node_b : edge.node_a)
      answer = Neighbour.new(edge:, node: other_node)
      # puts "found #{answer}"
      yield answer
    end
  end

  def dump
    instance_variables.sort.each do |ivar|
      p ivar
      case ivar
      when :@nodes_by_position
        @nodes_by_position.each do |position, node|
          puts "  #{position} -> #{node}"
        end
      when :@edges_by_position
        @edges_by_position.entries.sort_by(&:first).each do |position, edges|
          puts "  #{position}"
          edges.each do |edge|
            puts "    #{edge}"
          end
        end
      when :@current_node
        puts "  #{@current_node}"
      end
    end
  end

end
