#!/usr/bin/env ruby

$stdin.each_line do |text|
  m = text.match(/^(\d+)-(\d+) (\w): (\w+)$/)
  m or raise "? #{text}"

  min = m[1].to_i
  max = m[2].to_i
  letter = m[3]
  password = m[4]

  count = password.count(letter)
  ok = (count >= min and count <= max)
  print(ok ? "Y" : "n")
  print " " + text
end
