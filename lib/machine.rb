class Machine
  Halt = Class.new(RuntimeError)

  def initialize(memory)
    @memory = memory
    @position = 0
  end

  attr_reader :memory, :position

  def run
    while true
      run_one_instruction
    end
  rescue Halt
  end

  def run_one_instruction
    if position < 0 or position >= memory.length
      raise 'bad position'
    end

    case memory[position]
    when 1
      l_pos, r_pos, o_pos = [1,2,3].map do |i|
        raise 'bad position' if position+i >= memory.length
        value = memory[position+i]
        raise 'bad position' if value >= memory.length
        value
      end

      memory[o_pos] = memory[l_pos] + memory[r_pos]
      @position += 4
    when 2
      l_pos, r_pos, o_pos = [1,2,3].map do |i|
        raise 'bad position' if position+i >= memory.length
        value = memory[position+i]
        raise 'bad position' if value >= memory.length
        value
      end

      memory[o_pos] = memory[l_pos] * memory[r_pos]
      @position += 4
    when 99
      raise Halt
    else
      raise 'unexpected opcode'
    end
  end
end
