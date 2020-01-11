require 'machine'

class TractorBeam

  def initialize(program)
    @program = program
    @cache = {}
    @row_cache = {}
  end

  attr_reader :program, :cache, :row_cache

  def get(x, y)
    cache[[x,y]] ||= begin
      o = []
      machine = Machine::ArrayIO.new(program.dup, inputs: [x, y], outputs: o)
      machine.run
      o.first
    end
  end

  def map(width, height)
    (0...height).map do |y|
      (0...width).map do |x|
        get(x, y)
      end
    end
  end

  def count_affected_spaces(width, height)
    grid = map(width, height)

    grid.each do |row|
      puts row.map { |num| '.#'[num] }.join('')
    end

    grid.flatten.count { |num| num == 1 }
  end

  def filled_x_for_y(y)
    @row_cache[y] ||= begin
      if y < 5
        (0...10).select do |x|
          get(x, y) == 1
        end
      else
        xs = filled_x_for_y(y-1).dup

        raise "xs is empty!" if xs.empty?

        # Do we need to add any at the end?
        while get(xs.last + 1, y) == 1
          xs << xs.last + 1
        end

        # Do we need to discard any at the start?
        while !xs.empty? and get(xs.first, y) == 0
          xs.shift
        end

        raise "xs is empty!" if xs.empty?

        xs
      end
    end
  end

  def closest_place(ship_w, ship_h)
    try_y = 10

    while true
      xs = filled_x_for_y(try_y)

      if xs.count < ship_w
        try_y += 1
        next
      end

      min_x, max_x = xs.first, xs.last
      puts "#{try_y} -> #{min_x} #{max_x}"

      (min_x .. max_x).each do |possible_x|
        if fits_at?(ship_w, ship_h, possible_x, try_y)
          return [possible_x, try_y]

          # puts "Allegedly fits at #{possible_x} #{try_y}"
          # show_y_range = (try_y - 5 ... try_y + ship_h + 10)
          # show_x_range = (possible_x - 5 ... possible_x + ship_w + 10)
          #
          # puts "#{show_x_range.inspect} / #{show_y_range.inspect}"
          # show_y_range.each do |sy|
          #   cells = show_x_range.map {|sx| '.#'[get(sx, sy)] }.join('')
          #   puts "%6d %s" % [sy, cells]
          # end
        end
      end

      try_y += 1
    end

    nil
  end

  def fits_at?(ship_w, ship_h, x, y)
    (0...ship_h).all? do |y_offset|
      xs = filled_x_for_y(y + y_offset)
      puts "xs for #{y + y_offset} -> #{xs.first} #{xs.last}"
      xs.first <= x and xs.last >= x + ship_w - 1
    end
  end

end
