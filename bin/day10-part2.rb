#!/usr/bin/env ruby

require 'set'

@adapters = Set.new($stdin.each_line.map(&:chomp).map(&:to_i))
device = @adapters.max + 3
@cache = {}

def ways_of_reaching(target)
  @cache[target] ||= begin
    n = 0

    if target <= 3
      n += 1
    end

    [1, 2, 3].each do |jump|
      if @adapters.include?(target - jump)
        n += ways_of_reaching(target - jump)
      end
    end

    n
  end
end

puts ways_of_reaching(device)
