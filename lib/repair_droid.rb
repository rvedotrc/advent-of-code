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
    @panels = {}
    @start = Position.new(0, 0)

    # Places that we can definitely reach, to test what's there
    @to_explore = Set.new
    add_unknown(start)
    start.neighbours.values.each do |neighbour|
      add_unknown(neighbour)
      @panels[neighbour] = nil
    end
  end

  attr_reader :program, :map, :position, :to_explore, :plan, :start

  def run
    @position = start

    machine = Machine::Commandable.new(program)
    machine.start

    @plan = nil
    @previous_direction = 1

    @screen_origin = Position.new(-1, -1)
    redraw

    while true do
      machine.running? or raise 'machine crashed'

      if plan.nil? or plan.empty?
        @plan = nearest_to_explore(previous_direction: @previous_direction)
        break if @plan.nil?

        # puts "New plan! #{plan.inspect}"
      end

      raise if plan.nil? or plan.empty?

      dir, desired_position = plan.shift
      @previous_direction = dir
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
        old_position = position
        @position = desired_position
        draw_cell(old_position)
        draw_cell(position)
      when 2
        # moved and found
        fill_in(OXYGEN, desired_position)
        old_position = position
        @position = desired_position
        draw_cell(old_position)
        draw_cell(position)
      else
        raise "unexpected output #{answer}"
      end
    end

    machine.stop

    redraw
  end

  def load_map(text)
    @panels = {}

    text.lines.each_with_index do |row, y|
      row.chars.each_with_index do |char, x|
        pos = Position.new(x, y)
        case char
        when START
          @start = pos
          @panels[pos] = EMPTY
        when CURRENT
          @panels[pos] = EMPTY
        when WALL, EMPTY, OXYGEN
          @panels[pos] = char
        end
      end
    end

    @to_explore = Set.new

    puts *draw
  end

  def find_oxygen
    oxygen_positions = @panels.each_entry.map do |pos, what|
      pos if what == OXYGEN
    end.compact

    paths_to_oxygen = []
    breadth_first_paths_from(from: start) do |path|
      if oxygen_positions.include?(path.last.last)
        paths_to_oxygen << path
      end
    end

    paths_to_oxygen.sort_by!(&:length)
    paths_to_oxygen.each do |path|
      puts "#{path.count} steps: #{path.map(&:first).join(' ')}"
    end
  end

  def add_unknown(pos)
    if @panels[pos]
      raise "add_unknown #{pos} but we know what's there"
    end

    @to_explore << pos
    draw_cell(pos)
  end

  def draw
    x_values = @panels.keys.map(&:first).sort
    y_values = @panels.keys.map(&:last).sort

    (y_values.min .. y_values.max).map do |y|
      (x_values.min .. x_values.max).map do |x|
        what_to_render_at(x, y)
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

    if at.x < @screen_origin.x or at.y < @screen_origin.y
      @screen_origin = Position.new(
        [@screen_origin.x, at.x].min,
        [@screen_origin.y, at.y].min,
      )
      redraw
    else
      draw_cell(at)
    end

    if what == OXYGEN or what == EMPTY
      at.neighbours.values.each do |neighbour|
        unless @panels[neighbour]
          @to_explore.add(neighbour)
          draw_cell(neighbour)
        end
      end
    end
  end

  def redraw
    print "\ec\e[2J"
    puts *draw
  end

  def what_to_render_at(x, y)
    if [x, y] == position
      CURRENT
    elsif to_explore.include?(Position.new(x, y))
      EXPLORE
    elsif [x, y] == [0, 0]
      START
    else
      @panels[[x, y]] || UNKNOWN
    end
  end

  def draw_cell(at)
    @screen_origin or return
    print "\e[#{at.y - @screen_origin.y + 1};#{at.x - @screen_origin.x + 1}H"
    print what_to_render_at(*at)
  end

  def nearest_to_explore(previous_direction:)
    return nil if to_explore.empty?

    preferred_directions = PREFERRED_DIRECTIONS[previous_direction]

    breadth_first_paths_from(from: position, preferred_directions: preferred_directions) do |path|
      # p path
      ends_at = path.last.last
      if to_explore.include?(ends_at)
        return path
      end
    end

    raise "Didn't find a path to any to_explore positions"
  end

  def breadth_first_paths_from(from:, preferred_directions: nil)
    preferred_directions ||= PREFERRED_DIRECTIONS.values.first

    queue = [
      {
        must_not_visit: Set.new([from]),
        path: [],
        at: from,
      }
    ]

    until queue.empty?
      state = queue.shift

      yield state[:path] unless state[:path].empty?

      if @panels[state[:at]] or state[:at] == position
        neighbours = state[:at].neighbours

        preferred_directions.each do |dir|
          next unless move_to = neighbours[dir]
          next if state[:must_not_visit].include?(move_to)
          next unless [EMPTY, OXYGEN, nil].include?(@panels[move_to])

          queue.push(
            must_not_visit: state[:must_not_visit] + [move_to],
            path: state[:path] + [[dir, move_to]],
            at: move_to,
          )
        end
      end
    end
  end

  class Position < Array
    def initialize(x, y)
      super()
      self << x
      self << y
    end

    alias_method :x, :first
    alias_method :y, :last

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

  PREFERRED_DIRECTIONS = {
    1 => [1, 4, 2, 3].freeze,
    4 => [4, 2, 3, 1].freeze,
    2 => [2, 3, 1, 4].freeze,
    3 => [3, 1, 4, 2].freeze,
  }.freeze

end
