#!/usr/bin/env ruby

instructions = $stdin.each_line.map(&:chomp)
acc = 0
ip = 0

require 'set'
executed_ips = Set.new

while true
  unless executed_ips.add?(ip)
    puts acc
    exit
  end

  case instructions[ip]
  when nil
    raise "ip is #{ip}"
  when /^nop /
    ip += 1
  when /^acc ([+-]\d+)$/
    acc += $1.to_i
    ip += 1
  when /^jmp ([+-]\d+)$/
    ip += $1.to_i
  else
    raise "Unknown instruction #{instructions[ip]}"
  end
end
