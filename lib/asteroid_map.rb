require 'ostruct'

class AsteroidMap
  def initialize(grid)
    @grid = grid

    @asteroid_positions = grid.each_with_index.map do |row, y|
      row.chars.each_with_index.map do |char, x|
        if char == '#'
          [x, y]
        end
      end
    end.flatten(1).compact
  end

  def best_position
    @asteroid_positions.map do |position|
      count = detection_count_from(position)
      OpenStruct.new(position: position, count: count)
    end.sort_by(&:count).last
  end

  def can_see_a_from_b(a, b, on_this_line)
    @can_see ||= {}
    key = [a.position,b]
    reverse_key = [b,a.position]
    return @can_see[key] if @can_see.key?(key)

    answer = false

    answer = on_this_line.none? do |test|
      test.distance < a.distance
    end

    @can_see[reverse_key] = answer
    @can_see[key] = answer
  end

  def build_radial_map(base_position)
    radial_map = @asteroid_positions.map do |asteroid_position|
      unless asteroid_position == base_position
        dx = asteroid_position[0] - base_position[0]
        dy = asteroid_position[1] - base_position[1]

        angle_key = nil
        angle = nil

        if dy == 0
          angle_key = [ :x_axis, (dx > 0) ]

          angle = (
            (dx > 0) ? Math::PI/2 : 3*Math::PI/2
          )
        else
          angle_key = [ Rational(dx, dy), (dy > 0) ]

          angle = begin
            d = Math.atan(-1.0*dx/dy)
            d += Math::PI if dy > 0
            d
          end
        end

        OpenStruct.new(
          angle: angle,
          angle_key: angle_key,
          position: asteroid_position,
          distance: dx**2 + dy**2,
          dx: dx, dy: dy,
        )
      end
    end.compact.group_by(&:angle_key)
  end

  def detection_count_from(base_position)
    radial_map = build_radial_map(base_position)

    radial_map.each_entry.map do |angle, on_this_line|
      on_this_line.count do |this_asteroid|
        can_see_a_from_b(this_asteroid, base_position, on_this_line)
      end
    end.reduce(&:+)
  end

  def sweep_from(base_position)
    radial_map = build_radial_map(base_position)

    spokes = radial_map.values.sort_by do |spoke|
      angle = spoke.first.angle
      angle += 2 * Math::PI if angle < 0
      angle
    end

    spokes.each do |spoke|
      spoke.sort_by! &:distance
    end

    zapped = []

    while spokes.any?
      this_spoke = spokes.shift
      zapped << this_spoke.shift.position
      spokes.push(this_spoke) unless this_spoke.empty?
    end

    zapped
  end

end
