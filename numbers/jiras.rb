class Jiras
    STATES = [:open, :in_progress, :ready_for_review, :ready_for_acc_testing, :closed, :backlog]
    attr_accessor :domain, :jiras

    # Returns a new xml object restricted to a particular jira domain
    def initialize
        @jiras = []
        STATES.each do |state|
            find_all(state)
        end
        self
    end

    # Counts the number of jiras of a particular type (Bug, Story, etc) within
    # the given state (see Jiras::STATES)
    def count(type)
        sum = 0
        @jiras.count { |j| next unless j.type == type; sum += 1 }
        sum
    end

    # Returns the expected for all jiras of a state (see Jiras::STATES)
    def sum_expected
        @jiras.map(&:expected).inject { |sum, el| sum += el }
    end

    # Returns the expected for a type of jira (Story, Bug) for jiras of a
    # certain state (see JIRAS::STATES)
    def sum_expected_type(type)
        sum = 0.0
        @jiras.each do |j|
            next unless j.type == type
            sum += j.expected
        end
        sum
    end

    # Returns an array of Jira objects which fit the given domain
    def find_all(state)
        return [] unless @domain
        @domain.each do |item|
            next unless item.xpath(Paths::KEY)
            j = Jira.new(item.xpath(Paths::KEY))
            j.title = item.xpath(Paths::TITLE)
            j.expected = item.xpath(Paths::EXPECTED)
            j.type = item.xpath(Paths::TYPE)
            j.state = state
            @jiras << j
        end
    end

    # Set can be planned, added, or removed to represent those JIRAs
    def to_table(set = false)
        "#{@state.to_s[0..5].capitalize}\t\t|\t#{count("Story")}\t|\t#{count("Bug")}\t|\t#{sum_expected.to_f}"
    end
end
