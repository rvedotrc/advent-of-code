require 'ostruct'

class OreReactions

  class Reaction
    def initialize(inputs:, output:)
      @inputs = inputs
      @output = output
    end

    attr_reader :inputs, :output

    def to_s
      inputs.map(&:to_s).join(' + ') + " makes " + output.to_s
    end

    def inspect
      to_s
    end
  end

  class AmountOfSomething
    def initialize(amount:, of:)
      @amount = amount
      @of = of
    end

    attr_reader :amount, :of

    def to_s
      "#{amount} of #{of}"
    end

    def inspect
      to_s
    end
  end

  def initialize(input)
    @reactions = {}

    input.each_line do |line|
      m = line.match(/^\s*(.*?)\s*=>\s*(.*?)\s*$/)
      m or next

      inputs = m[1].split(/\s*,\s*/).map do |n_foo_text|
        parse_n_foo(n_foo_text)
      end

      output = parse_n_foo(m[2])

      raise if @reactions.key?(output.of)
      @reactions[output.of] = Reaction.new(
        inputs: inputs,
        output: output,
      )
    end
  end

  def ore_required_for(amount, of)
    @ore_consumed = 0
    @quantities = Hash.new do |hash, key|
      hash[key] = 0
    end
    consume(amount, of.to_s)
    @ore_consumed
  end

  def maximum_amount_of(output:, given_ore:)
    min = 0
    max = given_ore

    while min < max
      midpoint = ((min + max) / 2.0).ceil
      can_produce = ore_required_for(midpoint, output) <= given_ore
      puts [ min, max, midpoint, can_produce ].inspect

      if can_produce
        return midpoint if midpoint == max
        min = midpoint
      else
        return min if midpoint == max
        max = midpoint
      end
    end

    puts [ min, max ]
    raise
  end

  private

  attr_reader :reactions, :quantities, :ore_consumed

  def parse_n_foo(n_foo_text)
    m = n_foo_text.match(/^(\d+)\s+(\w+)$/)
    m or raise

    AmountOfSomething.new(amount: m[1].to_i, of: m[2])
  end

  def consume(amount, of, depth: 0)
    indent = '  ' * depth
    # puts indent + "Consume #{amount} of #{of}"

    if of == 'ORE'
      # puts indent + "Consuming #{amount} ORE"
      @ore_consumed += amount
      return
    end

    reaction = reactions[of] or raise 'No formula for making ' + of

    # puts indent + "Quantities = #{quantities.inspect}"

    if @quantities[of] < amount
      shortfall = amount - @quantities[of]
      reactions_needed = (1.0 * shortfall / reaction.output.amount).ceil
      # puts indent + "Running [#{reaction}] #{reactions_needed} times"

      reaction.inputs.each do |input|
        consume(reactions_needed * input.amount, input.of, depth: depth + 1)
      end

      @quantities[of] += reactions_needed * reaction.output.amount
      # puts indent + "Quantities = #{quantities.inspect}"
    end

    raise "Still not enough!" if @quantities[of] < amount
    @quantities[of] -= amount

    # puts indent + "Consuming #{amount} #{of}"
    # puts indent + "Quantities = #{quantities.inspect}"
  end

end
