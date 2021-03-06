require 'nokogiri'
require 'open-uri'
require 'paths'
require 'jira'
require 'jiras'
require 'sprint'
require 'comparator'


begin
    raise if ARGV.size !=2
    @@doc = Nokogiri::XML(open(ARGV[0]))
    @start_of_sprint = (ARGV[1].downcase.chomp == 's') ? true : false
rescue
    puts ""
    puts "Something went wrong. Did you specify the options correctly?"
    puts "Should be of format: $ this_file.rb _path_to_xml_file_ [s|e]"
    puts "You sure the file exists...?"
    puts "2nd arument should be s or e."
    puts "\ts: This is the start of the sprint"
    puts "\te: This is the end of the sprint"
    abort("")
end

@sprint = Sprint.new

if @start_of_sprint
    storage = File.open('snapshot.scrum_tools', 'w') 
else
    @comparator = Comparator.new('snapshot.scrum_tools')
end

puts "\n\nWeek: #{@sprint.week}\n\n"

puts "Here is what the current JIRA board looks like:"
Jiras::STATES.each do |state|
    puts "="*50
    puts "#{state.to_s.upcase} | Expected Sum: #{@sprint.sum_expected(state)}"
    puts "="*50
    @sprint.jiras.of_state(state).each do |j|
    #Jiras.new(state).find_all.each do |j|
        puts "#{j.key} | #{j.expected}\t| #{j.type}"
        if @start_of_sprint 
            # Serialize the jiras for comparison at the end of the sprint
            storage.puts j.to_csv 
        else
            # Find any JIRAs that may have been added/removed from the sprint
            case @comparator.check(j)
            when :planned then j.planned = true
            when :added then j.added = true
            when :removed then j.removed = true
            end
        end
    end
end

storage.close if @start_of_sprint

if !@start_of_sprint

    puts "\n\n\n And here is the table for the wiki \n\n\n"

    puts "|| || Stories || Bugs || Ideal Days ||"
    puts @sprint.jiras.to_table_top(:planned)
    puts @sprint.jiras.to_table_top(:added)
    puts @sprint.jiras.to_table_top(:removed)
    puts @sprint.jiras.to_table_top_totals

    puts @sprint.jiras.to_table(:closed)
    puts @sprint.jiras.to_table(:in_progress)
    puts @sprint.jiras.to_table(:open)
    puts @sprint.jiras.to_table(:backlog)

    puts "|| Carried Over || TBD || TBD || TBD ||\n\n"
end

