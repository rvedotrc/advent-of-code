#!/usr/bin/env ruby

passports = []
current = {}

$stdin.each_line do |line|
  if line.chomp == ''
    passports.push(current) unless current.empty?
    current = {}
  end

  line.split(' ').each do |pair|
    k, v = pair.split(':', 2)
    if current.key?(k)
      raise "already seen #{k} in #{current.inspect}"
    end
    current[k] = v
  end
end

passports.push(current) unless current.empty?

valid = passports.count do |pass|
  %w[
    byr
    iyr
    eyr
    hgt
    hcl
    ecl
    pid
  ].all? { |k| pass.key?(k) }
end

puts passports.count
puts valid
