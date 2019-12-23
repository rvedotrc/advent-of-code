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

    @screen_origin = Position.new(-1, -1)
    redraw

    while true do
      machine.running? or raise 'machine crashed'

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

    puts '-' * 80
    puts *draw
    puts
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

    p oxygen_positions

    paths_to_oxygen = []
    oxygen_positions.each do |oxygen_position|
      paths_from(from: start, to: oxygen_position) do |path|
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

  def nearest_to_explore
    return nil if to_explore.empty?

    to_explore.map do |target|
      next if target == position
      [target, position.distance_to(target)]
    end.compact.sort_by(&:last).first.first
  end

  def find_path(from:, to:)
    got = nil

    begin
      paths_from(from: from, to: to) do |path|
        got = path
        raise StopIteration
      end
    rescue StopIteration
    end

    got or raise "Didn't find a path!"

    got
  end

  def paths_from(from:, to:)
    # puts "Fun bit! Find all paths from #{from} to #{to}"

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

      if state[:at] == to
        yield state[:path]
      end

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

end
