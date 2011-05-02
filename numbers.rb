require 'nokogiri'

class Paths
    KEY = "../key"
    EXPECTED = "..//customfieldname[.='Expected']/../customfieldvalues"
    TITLE = "../title"
    TYPE = "../type"

    ### Status
    OPEN = "//status[.='Open']"
    IN_PROGRESS = "//status[.='In Progress']"
    RFR = "//status[.='Ready for Review']"
    RFAT = "//status[.='Ready for Acceptance Testing']"
    CLOSED = "//status[.='Closed']"
    BACKLOG = "//status[.='Backlog']"
end

class Jira
    attr_accessor :key, :title, :expected, :type

    def initialize(key)
        @key = (key) ? key[0].content.strip : ""
    end

    def expected=(e)
        if e == nil
            @expected = 0
        else
            @expected = (e[0]) ? ("%.2f" % e[0].content.strip).to_f : 0
        end
    end

    def type=(t)
        @type = (t) ? t[0].content.strip : ""
    end

end

class Jiras
    STATES = [:open, :in_progress, :ready_for_review, :ready_for_acc_testing, :closed, :backlog]
    attr_accessor :domain, :jiras

    # Returns a new xml object restricted to a particular jira domain
    def initialize(type)
        @domain = case type
                 when :open then @@doc.xpath(Paths::OPEN)
                 when :in_progress then @@doc.xpath(Paths::IN_PROGRESS)
                 when :ready_for_review then @@doc.xpath(Paths::RFR)
                 when :ready_for_acc_testing then @@doc.xpath(Paths::RFAT)
                 when :closed then @@doc.xpath(Paths::CLOSED)
                 when :backlog then @@doc.xpath(Paths::BACKLOG)
                 end
        find_all
        self
    end


    def size
        @jiras.size
    end

    def sum_expected
        @jiras.map(&:expected).inject { |sum, el| sum += el }
    end

    # Returns an array of Jira objects which fit the given domain
    def find_all
        return [] unless @domain

        types, titles, keys, expecteds = [], [], [], []
        @domain.each do |item|
            #item.xpath(Paths::TITLE)
            titles << item.xpath(Paths::TITLE)
            keys << item.xpath(Paths::KEY)
            expecteds << item.xpath(Paths::EXPECTED)
            types << item.xpath(Paths::TYPE)
        end

        #titles = @domain.xpath(Paths::TITLE)
        #keys = @domain.xpath(Paths::KEY)
        #expecteds = @domain.xpath(Paths::EXPECTED)

        @jiras = []

        (0..keys.size).each do 
            j = Jira.new(keys.shift)
            j.title = titles.shift
            j.expected = expecteds.shift
            j.type = types.shift
            @jiras << j
        end
        @jiras
    end
end

class Sprint
    attr_accessor :week
    def initialize
        parse_week
        @jiras = {}

        Jiras::STATES.each do |state|
            (@jiras[state.to_sym] = Jiras.new(state)).find_all
        end
    end

    def get_jiras(state)
        @jiras[state]
    end

    def sum_expected(state)
        get_jiras(state).sum_expected
    end

    #------
    private

    def parse_week
        @week = @@doc.xpath("//fixVersion")[0].content
    end
end


begin
    file = File.open(ARGV[0])
    @@doc = Nokogiri::XML(file)
rescue
    puts "Something went wrong. Did you specify the options correctly?"
    puts "Should be of format: $ this_file.rb _path_to_xml_file_"
    puts "You sure the file exists...?"
end

sprint = Sprint.new

puts "Week: #{sprint.week}"
Jiras::STATES.each do |state|
    puts "="*50
    puts "#{state.to_s.upcase} | Expected Sum: #{sprint.sum_expected(state)}"
    puts "="*50
    Jiras.new(state).find_all.each do |j|
        puts "#{j.key} | #{j.expected} | #{j.type}"
    end
end
