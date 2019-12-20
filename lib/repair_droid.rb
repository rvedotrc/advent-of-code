require 'machine'
require 'set'

class RepairDroid

  UNKNOWN = ' '
  EXPLORE = 'E'
  WALL = '#'
  EMPTY = '.'
  CURRENT = 'D'
  OXYGEN = 'O'
  START = 'S'

  def initialize(program)
    @program = program
  end

  attr_reader :program, :map, :position, :to_explore, :plan

  def run
    @panels = {}
    @position = Position.new(0, 0)
    @panels[@position] = nil

    # Places that we can definitely reach, to test what's there
    @to_explore = Set.new
    add_unknown(position)
    position.neighbours.values.each do |neighbour|
      add_unknown(neighbour)
    end

    machine = Machine::Commandable.new(program)
    machine.start

    @plan = nil

    while true do
      machine.running? or raise 'machine crashed'

      puts
      puts *draw
      # puts
      # puts to_explore.inspect

      if plan.nil? or plan.empty?
        where_to_test = nearest_to_explore
        break if where_to_test.nil?

        @plan = find_path(from: position, to: where_to_test)
        # puts "New plan! #{plan.inspect}"
      end

      raise if plan.nil? or plan.empty?

      dir, desired_position = plan.shift
      machine.input(dir)
      answer = machine.output

      case answer
      when 0
        # wall
        fill_in(WALL, desired_position)
        raise "Didn't expect a wall here!" unless plan.empty?
      when 1
        # moved
        fill_in(EMPTY, desired_position)
        @position = desired_position
      when 2
        # moved and found
        fill_in(OXYGEN, desired_position)
        @position = desired_position
      else
        raise "unexpected output #{answer}"
      end
    end

    machine.stop

    puts *draw
  end

  def add_unknown(pos)
    if @panels[pos]
      raise "add_unknown #{pos} but we know what's there"
    end

    @to_explore << pos
  end

  def draw
    x_values = @panels.keys.map(&:first).sort
    y_values = @panels.keys.map(&:last).sort

    (y_values.min .. y_values.max).map do |y|
      (x_values.min .. x_values.max).map do |x|
        if [x, y] == position
          CURRENT
        elsif to_explore.include?(Position.new(x, y))
          EXPLORE
        elsif [x, y] == [0, 0]
          START
        else
          @panels[[x, y]] || UNKNOWN
        end
      end.join('')
    end
  end

  def fill_in(what, at)
    already = @panels[at]

    if already and already != what
      raise "Already found #{already} at #{at} but now found #{what}"
    end

    @to_explore.delete(at)
    @panels[at] = what

    if what == OXYGEN or what == EMPTY
      at.neighbours.values.each do |neighbour|
        @to_explore.add(neighbour) unless @panels[neighbour]
      end
    end
  end

  def nearest_to_explore
    return nil if to_explore.empty?

    to_explore.map do |target|
      next if target == position
      [target, position.distance_to(target)]
    end.compact.sort_by(&:last).first.first
  end

  def find_path(from:, to:)
    # puts "Fun bit! Find a path from #{from} to #{to}"

    queue = [
      {
        must_not_visit: Set.new([from]),
        path: [],
        at: from,
      }
    ]

    until queue.empty?
      state = queue.shift
      # p state
      return state[:path] if state[:at] == to

      state[:at].neighbours.each do |dir, move_to|
        next if state[:must_not_visit].include?(move_to)

        if move_to == to
          next unless [EMPTY, OXYGEN, nil].include?(@panels[move_to])
        else
          next unless [EMPTY, OXYGEN].include?(@panels[move_to])
        end

        queue.unshift(
          must_not_visit: state[:must_not_visit] + [move_to],
          path: state[:path] + [[dir, move_to]],
          at: move_to,
        )
      end
    end

    raise "Didn't find a path!"
  end

  class Position < Array
    def initialize(x, y)
      super()
      self << x
      self << y
    end

    def neighbours
      # north (1), south (2), west (3), and east (4)
      x, y = self

      {
        1 => Position.new(x, y - 1),
        2 => Position.new(x, y + 1),
        3 => Position.new(x - 1, y),
        4 => Position.new(x + 1, y),
      }
    end

    def distance_to(other)
      (self[0] - other[0]).abs + (self[1] - other[1]).abs
    end
  end

end
