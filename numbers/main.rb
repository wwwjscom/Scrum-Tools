require 'nokogiri'
require 'paths'
require 'jira'
require 'jiras'
require 'sprint'
require 'comparator'


begin
    raise if ARGV.size !=2
    file = File.open(ARGV[0])
    @@doc = Nokogiri::XML(file)
    file.close
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
    Jiras.new(state).jiras.each do |j|
        puts "#{j.key} | #{j.expected}\t| #{j.type}"
        if @start_of_sprint 
            # Serialize the jiras for comparison at the end of the sprint
            storage.puts j.to_csv 
        else
            # Find any JIRAs that may have been added/removed from the sprint
            puts @comparator.check(j).class
            case @comparator.check(j)
            when :planned then j.planned = true
            when :added then j.added = true
            when :removed then j.removed = true
            end
        end
    end
end

storage.close if @start_of_sprint
jiras = Jiras.new

if !@start_of_sprint
    # Build the retrospective table
    completed = Jiras.new(:closed)
    incomplete = Jiras.new(:in_progress)
    not_started = Jiras.new(:open)

    puts "\t\t||\tStories\t||\tBugs\t||\tIdea Days\t||"
    puts completed.to_table
    puts incomplete.to_table
    puts not_started.to_table
end
