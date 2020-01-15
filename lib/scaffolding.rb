require 'machine'

class Scaffolding

  def initialize(program)
    @program = program
  end

  attr_reader :program, :grid

  def run
    grid_text = ''

    Machine.new(
      program,
      on_output: proc do |n|
        char = [n].pack('C')
        grid_text << char
      end,
    ).run

    @grid = grid_text.lines.map(&:chomp).map(&:chars)
  end

  def intersections
    intersections = []

    reader = proc do |x, y|
      (grid[y] || [])[x]
    end

    (0...grid.count).each do |y|
      (0...grid[0].count).each do |x|

        next unless reader.call(x, y) == '#'

        neighbours = 0
        neighbours += 1 if reader.call(x-1, y) == '#'
        neighbours += 1 if reader.call(x+1, y) == '#'
        neighbours += 1 if reader.call(x, y-1) == '#'
        neighbours += 1 if reader.call(x, y+1) == '#'

        if neighbours > 2
          intersections << [x, y]
        end
      end
    end

    intersections
  end

  def walk(main:, a:, b:, c:)
    copy_of_program = program.dup
    copy_of_program[0] = 2

    input = "#{main}\n#{a}\n#{b}\n#{c}\nn\n"
    outputs = []

    Machine::ArrayIO.new(
      copy_of_program,
      inputs: input.unpack("C*"),
      outputs: outputs,
    ).run

    outputs
  end

end
