class AmplifierChain

  require 'machine'

  def self.best_output_for(program)
    best = nil

    [0,1,2,3,4].permutation(5).each do |phases|
      this_output = run(program, phases)
      if !best or this_output > best
        best = this_output
      end
    end

    best
  end

  def self.run(program, phases)
    phases.reduce(0) do |signal, phase|
      m = Machine.new(program, inputs: [phase, signal])
      m.run
      m.outputs.last
    end
  end

  def self.best_feedback_output(program)
    best = nil

    [5,6,7,8,9].permutation(5).each do |phases|
      this_output = run_feedback(program, phases)
      if !best or this_output > best
        best = this_output
      end
    end

    best
  end

  class DataPipe
    def initialize(name)
      @name = name
      @queue = []
      @mutex = Mutex.new
      @cond = ConditionVariable.new
    end

    def empty?
      false
    end

    def shift
      @mutex.synchronize do
        while true
          unless @queue.empty?
            v = @queue.shift
            # puts "#{@name} shift #{v.inspect}"
            return v
          end
          # puts "Wait for #{@name}"
          @cond.wait(@mutex, 1)
        end
      end
    end
    
    def to_a
      @queue.dup
    end

    def <<(value)
      # puts "#{@name} << #{value.inspect}"
      @mutex.synchronize do
        @queue << value
        @cond.broadcast
      end
      self
    end
  end

  class TeeOutput
    def initialize(*sinks)
      @sinks = sinks
    end

    def <<(value)
      # puts "Tee << #{value.inspect}"
      @sinks.each do |sink|
        sink << value
      end
    end
  end

  def self.run_feedback(program, phases)
    final_output = DataPipe.new("final")

    inputs = phases.each_with_index.map do |phase, index|
      pipe = DataPipe.new("pipe#{index}")
      pipe << phase
      pipe
    end

    outputs = [inputs[1], inputs[2], inputs[3], inputs[4]]
    outputs << TeeOutput.new(inputs[0], final_output)

    machines = inputs.zip(outputs).map do |input, output|
      Machine.new(program.dup, inputs: input, outputs: output)
    end

    threads = machines.map do |m|
      Thread.new do
        begin
          m.run
        rescue Exception => e
          puts "crashed! #{e}"
        end
      end
    end

    inputs[0] << 0
    answer = final_output.shift
    threads.map(&:join)
    final_output.to_a.last
  end

end
