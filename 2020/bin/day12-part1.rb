#!/usr/bin/env ruby

COMPASS_VECTORS = {
  N: [0, +1],
  E: [+1, 0],
  S: [0, -1],
  W: [-1, 0],
}

ROTATION_90 = {
  E: :N,
  N: :W,
  W: :S,
  S: :E,
}

def run(state, instructions)
  instructions.each do |instruction|
    case instruction
    when /^([NSEW])(\d+)$/
      vector = COMPASS_VECTORS[$1.to_sym]
      arg = $2.to_i
      state = state.merge(
        x: state[:x] + vector[0] * arg,
        y: state[:y] + vector[1] * arg,
      )
    when /^([LR])(\d+)$/
      arg = $2.to_i
      if $1 == 'R'
        arg = 360 - arg
      end
      n = arg / 90
      state = state.merge(
        facing: n.times.reduce(state[:facing]) { |f| ROTATION_90[f] }
      )
    when /^(F)(\d+)$/
      arg = $2.to_i
      vector = COMPASS_VECTORS[state[:facing]]
      state = state.merge(
        x: state[:x] + vector[0] * arg,
        y: state[:y] + vector[1] * arg,
      )
    else
      raise "? #{instruction}"
    end
  end

  state
end

end_state = run({ x: 0, y: 0, facing: :E }, $stdin.each_line.map(&:chomp))
p end_state
puts(end_state[:x].abs + end_state[:y].abs)

