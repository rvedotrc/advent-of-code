class NBodyUniverse

  require 'ostruct'

  class CycleFoundException < Exception
    def initialize(length)
      @length = length
    end
    attr_reader :length
  end

  def initialize(dimensions: 3)
    @bodies = []
    @dimensions = dimensions
    @steps = 0
    @states = {}
  end

  attr_reader :bodies, :dimensions

  def add_body(position)
    position.count == dimensions or raise
    @bodies << OpenStruct.new(
      position: position,
      velocity: [0] * dimensions,
    )
  end

  def step
    state = current_state
    if @states[state] 
      raise CycleFoundException, @steps - @states[state]
    end
    @states[state] = @steps
    @steps += 1

    bodies.combination(2).each do |a, b|
      (0...dimensions).each do |dimension|
        if a.position[dimension] < b.position[dimension]
          a.velocity[dimension] += 1
          b.velocity[dimension] -= 1
        elsif a.position[dimension] > b.position[dimension]
          a.velocity[dimension] -= 1
          b.velocity[dimension] += 1
        end
      end
    end

    bodies.each do |body|
      (0...dimensions).each do |dimension|
        body.position[dimension] += body.velocity[dimension]
      end
    end

    bodies.each do |body|
      body.pot = body.position.map(&:abs).reduce(&:+)
      body.kin = body.velocity.map(&:abs).reduce(&:+)
      body.energy = body.pot * body.kin
    end
  end

  def current_state
    bodies.map do |body|
      body.position.map(&:to_s).join(',') + ":" + body.velocity.map(&:to_s).join(',')
    end.join(' ')
  end

  def cycle_time
    begin
      while true
        step
        puts @steps if @steps % 10000 == 0
      end
    rescue CycleFoundException => e
      e.length
    end
  end

  def fast_cycle_time
    if dimensions == 1
      return cycle_time
    end

    cycle_lengths = (0...dimensions).map do |dimension|
      one_d_universe = self.class.new(dimensions: 1)
      bodies.each do |body|
        raise unless body.velocity[dimension] == 0
        one_d_universe.add_body([ body.position[dimension] ])
      end
      one_d_universe.fast_cycle_time
    end

    cycle_lengths.reduce(&:lcm)
  end

end
