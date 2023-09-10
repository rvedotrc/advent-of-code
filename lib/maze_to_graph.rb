require 'ostruct'
require 'set'

class MazeToGraph

  Node = Data.define(:position, :what)
  Edge = Data.define(:position_a, :position_b, :distance)
  Neighbour = Data.define(:edge, :node)

  def initialize(maze)
    maze = maze.gsub(/^\s+/, '')

    rows = maze.lines.map(&:chomp)

    @nodes_by_position = {}
    @current_node = nil

    @edges_by_position = {}

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

        add_edge(position_a: node.position, position_b: neighbour.position, distance: 1)
      end
    end

    check!
  end

  def add_node(position:, what:)
    # puts "#{object_id} add node #{position} #{what}"
    raise if @nodes_by_position.key?(position)

    new_node = Node.new(position: position, what: what)

    @nodes_by_position[position] = new_node
    @current_node = new_node if what == '@'
  end

  def remove_node(node)
    # puts "#{object_id} remove node #{node}"
    @nodes_by_position.delete(node.position) or raise
    @current_node = nil if node.what == '@'
  end

  def add_edge(position_a:, position_b:, distance:)
    # puts "#{object_id} add edge #{position_a} #{position_b} #{distance}"
    return if position_a == position_b

    position_a, position_b = position_b, position_a if position_a > position_b

    existing_edge = @edges_by_position[position_a]&.find { |e| e.position_b == position_b }

    if existing_edge
      if existing_edge.distance <= distance
        # puts "#{object_id} existing edge #{existing_edge} is cheaper"
        return
      end

      @edges_by_position[position_a].delete(existing_edge)
      @edges_by_position[position_b].delete(existing_edge)
    end

    edge = Edge.new(position_a:, position_b:, distance:)
    (@edges_by_position[position_a] ||= []) << edge
    (@edges_by_position[position_b] ||= []) << edge

    raise @edges_by_position.inspect if @edges_by_position.values.any?(&:empty?)
  end

  def remove_edge(edge)
    # puts "#{object_id} remove edge #{edge}"

    [:position_a, :position_b].each do |ab|
      position = edge.public_send(ab)
      edges = (@edges_by_position[position] ||= [])

      index = edges.index(edge)
      raise "Edge #{edge} not found in index at #{edge.position_a}" if index.nil?

      edges.delete_at(index)
      @edges_by_position.delete(position) if edges.empty?
    end

    raise @edges_by_position.inspect if @edges_by_position.values.any?(&:empty?)
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

    position_name = lambda { |position| "p_#{position}" }

    nodes.each do |node|
      puts "  #{position_name.call(node.position)} [label=\"#{node.what}\"]"
    end

    edges.each do |edge|
      positions = [edge.position_a, edge.position_b].map(&position_name).join(' -- ')
      puts "  #{positions} [ label=\"#{edge.distance}\"]"
    end

    puts "}"
  end

  def reduce!
    while true
      break if !reduce_intermediate_nodes! && !reduce_dead_ends!
    end

    check!
  end

  def reduce_dead_ends!
    changed = false

    while true
      node_to_remove = nodes.find do |node|
        node.what == '.' and count_neighbours(node) == 1
      end

      node_to_remove or break

      # puts "#{object_id} remove dead end #{node_to_remove}"

      # Should only be 1 neighbour
      neighbours_of(node_to_remove).each do |neighbour|
        remove_edge(neighbour.edge)
      end

      remove_node(node_to_remove)

      check!

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

      # puts "#{object_id} remove intermediate #{node_to_remove} with #{count_neighbours(node_to_remove)} neighbours"
      neighbours = neighbours_of(node_to_remove).to_a

      # First remove the node and its edges
      neighbours.map(&:edge).each { |edge| remove_edge(edge) }
      remove_node(node_to_remove)

      # Then add an edge between all combinations of neighbours
      neighbours.combination(2).each do |a, b|
        add_edge(
          position_a: a.node.position,
          position_b: b.node.position,
          distance: a.edge.distance + b.edge.distance,
        )
      end

      check!

      changed = true
    end

    changed
  end

  def count_neighbours(node)
    @edges_by_position[node.position]&.count || 0
  end

  def neighbours_of(node)
    return enum_for(:neighbours_of, node) unless block_given?

    # puts "#{object_id} neighbours of #{node}"
    @edges_by_position[node.position]&.each do |edge|
      other_position = (edge.position_a == node.position ? edge.position_b : edge.position_a)
      other_node = @nodes_by_position[other_position]
      answer = Neighbour.new(edge:, node: other_node)
      # puts "#{object_id} found #{answer}"
      yield answer
    end
  end

  def dump
    puts "#{object_id} dump:"

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

  def hash
    [
      @nodes_by_position.hash,
      @edges_by_position.transform_values do |edges|
        edges.map(&:hash).sort
      end.hash,
      @current_node.hash,
    ].hash
  end

  def check!
    return
    e = errors

    if e.any?
      puts "#{object_id} check! failure"
      puts *e
      dump
      raise "Aborted"
    end
  end

  def errors
    return enum_for(:errors).to_a unless block_given?

    @nodes_by_position.each do |position, node|
      yield "nbp #{position} #{node}" if node.position != position
    end

    @edges_by_position.each do |position, edges|
      yield "ebp #{position} is empty" if edges.empty?
    end
  end

  def each_neighbouring_key
    neighbours_of(current_node).select { |n| n.node.what.match?(/[a-z]/) }
  end

  def dup
    parent = self
    check!

    copy = super.instance_eval do
      # puts "dup #{parent.object_id} -> #{object_id}"
      check!

      @nodes_by_position = @nodes_by_position.dup
      @edges_by_position = @edges_by_position.transform_values(&:dup)

      check!
      self
    end
  end

  # Returns a new graph
  def move_to(neighbouring_key)
    raise unless neighbouring_key.node.what.match?(/[a-z]/)

    dup.instance_eval do
      old_current = current_node
      new_current = neighbouring_key.node
      door = nodes.find { |n| n.what == new_current.what.upcase }

      # puts "#{object_id} before move #{old_current} -> #{new_current} (door=#{door}):"
      # dump

      check!

      replace_node(old_current, '.')
      check!
      replace_node(new_current, '@')
      check!
      replace_node(door, '.') if door

      check!

      # puts "#{object_id} after move:"
      # dump

      reduce!
      check!

      self
    end
  end

  private

  def replace_node(node, what)
    remove_node(node)
    add_node(position: node.position, what:)
  end

end
