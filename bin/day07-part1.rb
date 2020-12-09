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

def can_contain?(map, key, needle)
  map[key].any? do |inner|
    inner[:key] == needle or can_contain?(map, inner[:key], needle)
  end
end

puts map.keys.select { |k| can_contain?(map, k, "shiny gold bag") }.count
