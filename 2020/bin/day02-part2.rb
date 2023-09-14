#!/usr/bin/env ruby

$stdin.each_line do |text|
  m = text.match(/^(\d+)-(\d+) (\w): (\w+)$/)
  m or raise "? #{text}"

  pos1 = m[1].to_i
  pos2 = m[2].to_i
  letter = m[3]
  password = m[4]

  ok = ((password[pos1 - 1] == letter) ^ (password[pos2 - 1] == letter))
  print(ok ? "Y" : "n")
  print " " + text
end
