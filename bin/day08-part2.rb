#!/usr/bin/env ruby

require 'set'

InfiniteLoopException = Class.new(StandardError)
ExitException = Class.new(StandardError)

def run(instructions, acc = 0, ip = 0)
  executed_ips = Set.new

  while true
    unless executed_ips.add?(ip)
      raise InfiniteLoopException, acc
    end

    if ip == instructions.length
      raise ExitException, acc
    end

    case instructions[ip]
    when nil
      raise "ip is #{ip}"
    when /^nop ([+-]\d+)$/
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
end

instructions = $stdin.each_line.map(&:chomp)

reachable_from_start = Set.new

q = [0]
while ip = q.shift
  next unless reachable_from_start.add?(ip)

  case instructions[ip]
  when nil
    raise "ip is #{ip}"
  when /^nop ([+-]\d+)$/
    q.push(ip + 1)
  when /^acc ([+-]\d+)$/
    q.push(ip + 1)
  when /^jmp ([+-]\d+)$/
    q.push(ip + $1.to_i)
  else
    raise "Unknown instruction #{instructions[ip]}"
  end
end

reaches_end = Set.new
q = [instructions.length]

while ip = q.shift
  next unless reaches_end.add?(ip)

  if ip > 0
    if instructions[ip - 1].match(/^(nop|acc) /)
      q.push(ip - 1)
    end
  end

  instructions.each_with_index do |instr, idx|
    if instr.match(/^jmp (\S+)$/) && idx + $1.to_i == ip
      q.push(idx)
    end
  end
end

# jmp => nop?
reachable_from_start.each do |ip|
  if instructions[ip].start_with?('jmp ') && reaches_end.include?(ip + 1)
    puts "Change #{ip} to nop"

    copy = instructions.dup
    copy[ip] = copy[ip].sub(/jmp/, 'nop')

    begin
      run(copy)
    rescue ExitException => e
      puts e.message
    end
  end
end

