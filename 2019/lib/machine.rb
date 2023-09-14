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

  def initialize(memory, on_input: nil, on_output: nil)
    @memory = memory
    @position = 0
    @on_input = on_input
    @on_output = on_output
  end

  attr_reader :memory, :position, :on_input, :on_output

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
      poke(
        get_position(0, instruction),
        on_input.call,
      )
      @position += 2
    when 4
      on_output.call(
        get_arg(0, instruction)
      )
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

class Machine::ArrayIO < Machine

  def initialize(memory, inputs: [], outputs: [])
    @inputs = inputs
    @outputs = outputs
    super(
      memory,
      on_input: proc { inputs.shift },
      on_output: proc { |v| outputs << v },
     )
  end

  attr_reader :inputs, :outputs

end

class Machine::Commandable

  # Imperative form of Machine
  #
  # machine = Machine::Commandable.new(program)
  # machine.start
  # machine.running?
  # machine.input(n)
  # machine.output # => n
  # machine.stop

  def initialize(program)
    @machine = Machine.new(
      program,
      on_input: method(:on_input),
      on_output: method(:on_output),
    )
    @thread = nil

    @mutex = Mutex.new
    @cond = ConditionVariable.new
    @inputs = []
    @outputs = []
  end

  def start
    if @thread.nil?
      @thread = Thread.new { @machine.run }
    else
      raise 'already running'
    end
  end

  def running?
    if @thread
      return true if @thread.alive?
      @thread.join
    else
      false
    end
  end

  def stop
    if @thread
      @thread.kill
      @thread = nil
    else
      raise 'not running'
    end
  end

  def input(n)
    raise 'not running' unless running?

    @mutex.synchronize do
      @inputs << n
    end

    nil
  end

  def output
    raise 'not running' unless running?

    @mutex.synchronize do
      while @outputs.empty?
        @cond.wait(@mutex)
      end
      @outputs.shift
    end
  end

  private

  def on_input
    @mutex.synchronize do
      while @inputs.empty?
        @cond.wait(@mutex, 0.01)
      end
      @inputs.shift
    end
  end

  def on_output(n)
    @mutex.synchronize do
      @outputs << n
      @cond.broadcast
    end
  end

end
