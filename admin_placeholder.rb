#!/usr/bin/env ruby -w

print "Whats the sprint estimate?\t"
est = gets.chomp.to_f
print "How many developers are on the team?\t"
devs = gets.chomp.to_f
print "How many days will everyone be out?\t"
days = gets.chomp.to_f

admin = ( days * est ) / ( devs * 10.0 )
puts "The admin estimate is #{admin}"
