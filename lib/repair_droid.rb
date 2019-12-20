require 'machine'

class RepairDroid

  UNKNOWN = '?'
  WALL = '#'
  EMPTY = ' '
  CURRENT = 'D'
  OXYGEN = 'O'

  def initialize(program)
    @program = program
  end

  attr_reader :program, :map, :position

  def run
    @panels = {}
    @position = [0, 0]
    @panels[@position] = nil

    machine = Machine::Commandable.new(program)
    machine.start

    1000.times do
      machine.running? or raise 'machine crashed'

      puts
      puts *draw

      # north (1), south (2), west (3), and east (4)
      dir = rand(4) + 1

      desired_position = \
      case dir
      when 1
        [position[0], position[1]-1]
      when 2
        [position[0], position[1]+1]
      when 3
        [position[0]-1, position[1]]
      when 4
        [position[0]+1, position[1]]
      end

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

  def draw
    x_values = @panels.keys.map(&:first).sort
    y_values = @panels.keys.map(&:last).sort

    (y_values.min .. y_values.max).map do |y|
      (x_values.min .. x_values.max).map do |x|
        if [x, y] == position
          CURRENT
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

    @panels[at] = what
  end

end
