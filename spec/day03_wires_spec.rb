require 'wires'

RSpec.describe Wires do

  describe '#closest_intersection_distance' do
    it 'passes example 1' do
      w = Wires.new
      w.add_path(:a, 'R75,D30,R83,U83,L12,D49,R71,U7,L72')
      w.add_path(:b, 'U62,R66,U55,R34,D71,R55,D58,R83')
      expect(w.closest_intersection_distance).to eq(159)
    end
    it 'passes example 2' do
      w = Wires.new
      w.add_path(:a, 'R98,U47,R26,D63,R33,U87,L62,D20,R33,U53,R51')        
      w.add_path(:b, 'U98,R91,D20,R16,D67,R40,U7,R15,U6,R7')
      expect(w.closest_intersection_distance).to eq(135)
    end
  end

  describe '#fewest_intersection_steps' do
    it 'passes example 1' do
      w = Wires.new
      w.add_path(:a, 'R75,D30,R83,U83,L12,D49,R71,U7,L72')
      w.add_path(:b, 'U62,R66,U55,R34,D71,R55,D58,R83')
      expect(w.fewest_intersection_steps).to eq(610)
    end
    it 'passes example 2' do
      w = Wires.new
      w.add_path(:a, 'R98,U47,R26,D63,R33,U87,L62,D20,R33,U53,R51')        
      w.add_path(:b, 'U98,R91,D20,R16,D67,R40,U7,R15,U6,R7')
      expect(w.fewest_intersection_steps).to eq(410)
    end
  end

end
