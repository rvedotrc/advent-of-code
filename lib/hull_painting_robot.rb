require 'machine'

class HullPaintingRobot

  COMPASS = [:N, :E, :S, :W]

  def initialize(program)
    @program = program
    @panels = {}
    @x = 0
    @y = 0
    @direction = :N
  end

  attr_reader :panels

  def paint(position, colour)
    @panels[position] = colour
  end

  def run
    to_colour = nil

    machine = Machine.new(@program,
      on_input: proc { @panels[ [@x,@y] ] || 0 },
      on_output: proc do |value|
        puts "output = #{value}"

        if to_colour.nil?
          to_colour = value
        else
          turn = value

          @panels[ [@x,@y] ] = to_colour

          dir = (turn == 0 ? -1 : +1)
          index = (COMPASS.index(@direction) + dir + COMPASS.length)
          @direction = COMPASS[index % COMPASS.length]

          case @direction
          when :N
            @y -= 1
          when :E
            @x += 1
          when :S
            @y += 1
          when :W
            @x -= 1
          else
            raise
          end

          to_colour = nil
        end
      end,
    )
    machine.run
  end

  def draw
    x_values = @panels.keys.map(&:first).sort
    y_values = @panels.keys.map(&:last).sort

    (y_values.min .. y_values.max).map do |y|
      (x_values.min .. x_values.max).map do |x|
        @panels[ [x,y] ] == 0 ? '.' : '#'
      end.join('')
    end
  end

end
