#!/usr/bin/env ruby

COMPASS_VECTORS = {
  N: [0, +1],
  E: [+1, 0],
  S: [0, -1],
  W: [-1, 0],
}

def run(state, instructions)
  instructions.each do |instruction|
    case instruction
    when /^([NSEW])(\d+)$/
      vector = COMPASS_VECTORS[$1.to_sym]
      arg = $2.to_i
      state = state.merge(
        waypoint_x: state[:waypoint_x] + vector[0] * arg,
        waypoint_y: state[:waypoint_y] + vector[1] * arg,
      )
    when /^([LR])(\d+)$/
      arg = $2.to_i
      if $1 == 'R'
        arg = 360 - arg
      end
      n = arg / 90
      n.times do
        state = state.merge(
          waypoint_x: -state[:waypoint_y],
          waypoint_y: +state[:waypoint_x],
        )
      end
    when /^(F)(\d+)$/
      arg = $2.to_i
      state = state.merge(
        x: state[:x] + state[:waypoint_x] * arg,
        y: state[:y] + state[:waypoint_y] * arg,
      )
    else
      raise "? #{instruction}"
    end
  end

  state
end

end_state = run({ x: 0, y: 0, waypoint_x: 10, waypoint_y: 1 }, $stdin.each_line.map(&:chomp))
p end_state
puts(end_state[:x].abs + end_state[:y].abs)

