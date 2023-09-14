require 'machine'

class ArcadeGame

  RENDERED = [' ', '#', '.', '=', 'o']

  def initialize
    @grid = {}
  end

  def run(program)
    buffer = []
    on_output = proc do |n|
      buffer << n
      if buffer.count == 3
        x, y, type = buffer
        @grid[ [x, y] ] = RENDERED[type]
        buffer = []
      end
    end

    machine = Machine.new(program, on_output: on_output)
    machine.run
  end

  def run_interactive(program)
    score = nil

    ball_x = nil
    bat_x = nil

    buffer = []
    on_output = proc do |n|
      buffer << n
      if buffer.count == 3
        x, y, type = buffer
        if x == -1 and y == 0
          score = type
        else
          @grid[ [x, y] ] = RENDERED[type]
          ball_x = x if type == 4
          bat_x = x if type == 3
        end
        buffer = []
      end
    end

    on_input = proc do
      # puts
      # puts *draw
      # puts score

      if ball_x > bat_x
        +1
      elsif ball_x < bat_x
        -1
      else
        0
      end
    end

    machine = Machine.new(
      program,
      on_input: on_input,
      on_output: on_output,
    )
    machine.run

    score
  end

  def draw
    x_values = @grid.keys.map(&:first).sort
    y_values = @grid.keys.map(&:last).sort

    (y_values.min .. y_values.max).map do |y|
      (x_values.min .. x_values.max).map do |x|
        @grid[ [x,y] ] || ' '
      end.join('')
    end
  end

end
