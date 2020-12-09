#!/usr/bin/env ruby

map = $stdin.each_line.map do |line|
  m = line.match(/^(.*? bag)s contain (.*)\.$/)
  m or raise "? #{line}"

  outer = m[1]

  inners = if m[2] == "no other bags"
    []
  else
    m[2].split(/, /).map do |part|
      part_match = part.match(/^(\d+) (.*? bag)s?$/)
      part_match or raise "? #{part}"
      { count: part_match[1].to_i, key: part_match[2] }
    end
  end

  [ outer, inners ]
end.to_h

def self_plus_contents_count(map, key)
  inner_counts = map[key].map do |inner|
    inner[:count] * self_plus_contents_count(map, inner[:key])
  end

  1 + inner_counts.sum
end

puts self_plus_contents_count(map, "shiny gold bag") - 1
