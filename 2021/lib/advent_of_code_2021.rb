# frozen_string_literal: true

require_relative './advent_of_code_2021/base'

module AdventOfCode2021
  @mutex = Mutex.new

  def self.const_missing(const)
    if day = const.to_s[/^Day(\d+)$/, 1]
      @mutex.synchronize do
        require_relative "./advent_of_code_2021/day#{day}"
      end

      return const_get("Day#{day}")
    end

    super
  end

  def self.test(day_number, part_number)
    klass = const_get("Day#{day_number}").const_get("Part#{part_number}")
    File.open("input/day#{day_number}") do |fh|
      klass.run(fh)
    end
  end
end
