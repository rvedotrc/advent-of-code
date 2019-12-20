require 'machine'
require 'set'

class RepairDroid

  UNKNOWN = '?'
  EXPLORE = 'E'
  WALL = '#'
  EMPTY = ' '
  CURRENT = 'D'
  OXYGEN = 'O'

  def initialize(program)
    @program = program
  end

  attr_reader :program, :map, :position, :to_explore

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

    while true do
      machine.running? or raise 'machine crashed'

      puts
      puts *draw
      puts
      puts to_explore.inspect

      neighbours = position.neighbours

      dir, desired_position = neighbours.entries.shuffle.first

      machine.input(dir)

      answer = machine.output

      case answer
      when 0
        # wall
        fill_in(WALL, desired_position)
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
  end

end
