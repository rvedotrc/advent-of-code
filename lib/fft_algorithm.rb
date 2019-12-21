class FFTAlgorithm

  def initialize(input)
    @input = input.chars.map(&:to_i)
    @multipliers_for_row = {}
  end

  attr_reader :input

  def next(steps = 1)
    steps.times do
      @input = (0...input.length).map do |row_index|
        multipliers = multipliers_for_row(row_index)
        sum = input.zip(multipliers).map { |pair| pair.first * pair.last }.reduce(&:+)
        sum.abs % 10
      end
      p input
    end

    input.join('')
  end

  def multipliers_for_row(row_index)
    @multipliers_for_row[row_index] ||= begin
      sequence = [0, 1, 0, -1]

      sequence = sequence.flat_map do |i|
        [i] * (row_index+1)
      end

      while sequence.length < input.length+1
        sequence = sequence + sequence
      end

      sequence.shift

      sequence.take(input.length)
    end
  end

end
