#!/usr/bin/env ruby

def valid?(pass)
  v = pass['byr']
  return false unless v and v.match(/^\d{4}$/) and v.to_i >= 1920 and v.to_i <= 2002

  v = pass['iyr']
  return false unless v and v.match(/^\d{4}$/) and v.to_i >= 2010 and v.to_i <= 2020

  v = pass['eyr']
  return false unless v and v.match(/^\d{4}$/) and v.to_i >= 2020 and v.to_i <= 2030

  v = pass['hgt']
  return false unless v and (
    (m = v.match(/^(\d{3})cm$/) and m[1].to_i >= 150 and m[1].to_i <= 193) \
    or \
    (m = v.match(/^(\d{2})in$/) and m[1].to_i >= 59 and m[1].to_i <= 76)
  )

  v = pass['hcl']
  return false unless v and v.match(/^#[0-9a-f]{6}$/)

  v = pass['ecl']
  return false unless v and v.match(/^(amb|blu|brn|gry|grn|hzl|oth)$/)

  v = pass['pid']
  return false unless v and v.match(/^\d{9}$/)

  true
end

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
  valid?(pass)
end

puts passports.count
puts valid
