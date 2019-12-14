class Machine
  def self.output_of(input, position = 0)
    if position < 0 or position >= input.length
      raise 'bad position'
    end

    case input[position]
    when 1
      l_pos, r_pos, o_pos = [1,2,3].map do |i|
        raise 'bad position' if position+i >= input.length
        value = input[position+i]
        raise 'bad position' if value >= input.length
        value
      end

      output = input.dup
      output[o_pos] = output[l_pos] + output[r_pos]
      output_of(output, position+4)
    when 2
      l_pos, r_pos, o_pos = [1,2,3].map do |i|
        raise 'bad position' if position+i >= input.length
        value = input[position+i]
        raise 'bad position' if value >= input.length
        value
      end

      output = input.dup
      output[o_pos] = output[l_pos] * output[r_pos]
      output_of(output, position+4)
    when 99
      input
    else
      raise 'unexpected opcode'
    end
  end
end
