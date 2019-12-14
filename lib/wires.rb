class Wires
  def initialize
    @cells = {}
  end

  def add_path(colour, path)
    position = [0,0]
    steps = 0

    path.split(/,/).each do |instruction|
      vector = case instruction[0]
               when 'U'
                 [0,+1]
               when 'D'
                 [0,-1]
               when 'R'
                 [+1,0]
               when 'L'
                 [-1,0]
               else
                 raise
               end

      distance = instruction[1..-1].to_i

      distance.times do
        steps += 1
        new_position = position.zip(vector).map {|pairs| pairs.reduce(&:+)}
        cell = (@cells[new_position] ||= {})
        cell[colour] ||= steps
        position = new_position
      end
    end
  end

  def all_intersections
    @cells.entries.map do |position, colours|
      position if colours.count > 1
    end.compact
  end

  def closest_intersection_distance
    all_intersections.map do |position|
      distance = position.map(&:abs).reduce(&:+)
      [ position, distance ]
    end.sort_by(&:last).first.last
  end

  def fewest_intersection_steps
    all_intersections.map do |position|
      steps = @cells[position].values.reduce(&:+)
      [ position, steps ]
    end.sort_by(&:last).first.last
  end
end
