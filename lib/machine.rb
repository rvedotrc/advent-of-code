class Machine
  Halt = Class.new(RuntimeError)

  NAMES = {
    1 => 'add',
    2 => 'multiply',
    3 => 'input',
    4 => 'output',
    5 => 'jump-if-true',
    6 => 'jump-if-false',
    7 => 'less than',
    8 => 'equals',
    9 => 'adjust relative base',
    99 => 'halt',
  }

  def initialize(memory, inputs: [], outputs: [])
    @memory = memory
    @position = 0
    @inputs = inputs
    @outputs = outputs
  end

  attr_reader :memory, :position, :inputs, :outputs

  def run
    @relative_base = 0
    while true
      run_one_instruction
    end
  rescue Halt
  end

  def run_one_instruction
    instruction = peek(position)
    # p [ instruction, NAMES[ instruction % 100 ] ]

    case instruction % 100
    when 1
      poke(
        get_position(2, instruction),
        get_arg(0, instruction) + get_arg(1, instruction)
      )
      @position += 4
    when 2
      poke(
        get_position(2, instruction),
        get_arg(0, instruction) * get_arg(1, instruction)
      )
      @position += 4
    when 3
      raise 'no more inputs' if inputs.empty?
      poke(
        get_position(0, instruction),
        inputs.shift,
      )
      @position += 2
    when 4
      outputs << get_arg(0, instruction)
      @position += 2
    when 5
      if get_arg(0, instruction) != 0
        @position = get_arg(1, instruction)
      else
        @position += 3
      end
    when 6
      if get_arg(0, instruction) == 0
        @position = get_arg(1, instruction)
      else
        @position += 3
      end
    when 7
      value = if get_arg(0, instruction) < get_arg(1, instruction)
                1
              else
                0
              end
      poke(get_position(2, instruction), value)
      @position += 4
    when 8
      value = if get_arg(0, instruction) == get_arg(1, instruction)
                1
              else
                0
              end
      poke(get_position(2, instruction), value)
      @position += 4
    when 9
      @relative_base += get_arg(0, instruction)
      @position += 2
    when 99
      raise Halt
    else
      raise 'unexpected opcode'
    end
  end

  def get_position(seq, instruction)
    mode = (instruction / 10**(seq+2)) % 10
    case mode
    when 0
      peek(@position + 1 + seq)
    when 2
      @relative_base + peek(@position + 1 + seq)
    else
      raise 'bad mode'
    end
  end

  def get_arg(seq, instruction)
    r = begin
      mode = (instruction / 10**(seq+2)) % 10
      case mode
      when 0
        peek( peek(@position + 1 + seq) )
      when 1
        peek(@position + 1 + seq)
      when 2
        peek ( @relative_base + peek(@position + 1 + seq) )
      else
        raise 'bad mode'
      end
    end

    # puts "get_arg #{seq} #{instruction} => #{r}"
    r
  end

  def peek(pos)
    raise "bad position" if pos < 0
    if pos >= memory.length
      memory.concat([0] * (pos - memory.length + 1))
    end
    raise "bad position" if pos < 0 or pos >= memory.length
    r = memory[pos]
    # puts "peek #{pos} => #{r}"
    r
  end

  def poke(pos, value)
    raise "bad position #{pos} (0...#{memory.length})" if pos < 0
    if pos >= memory.length
      memory.concat([0] * (pos - memory.length + 1))
    end
    raise "bad position #{pos} (0...#{memory.length})" if pos < 0 or pos >= memory.length
    memory[pos] = value
    # puts "poke #{pos}, #{value}"
  end

end
