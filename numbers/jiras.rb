class Jiras
    STATES = [:backlog, :open, :in_progress, :ready_for_review, :ready_for_acc_testing, :closed]
    attr_accessor :jiras

    # Returns a new xml object restricted to a particular jira domain
    def initialize
        @jiras = []
        STATES.each do |state|
            domain = case state
                      when :open then @@doc.xpath(Paths::OPEN)
                      when :in_progress then @@doc.xpath(Paths::IN_PROGRESS)
                      when :ready_for_review then @@doc.xpath(Paths::RFR)
                      when :ready_for_acc_testing then @@doc.xpath(Paths::RFAT)
                      when :closed then @@doc.xpath(Paths::CLOSED)
                      when :backlog then @@doc.xpath(Paths::BACKLOG)
                      end
            find_all(domain, state)
        end
        self
    end

    def of_state(state)
        arr = []
        @jiras.each { |j| arr << j if j.state == state }
        arr
    end

    def of_type_and_temporal(type, temporal)
        arr = []
        @jiras.each { |j| arr << j if j.type == type && j.temporal == temporal }
        arr
    end

    # Counts the number of jiras of a particular type (Bug, Story, etc) within
    # the given state (see Jiras::STATES)
    def count(type, state)
        sum = 0
        @jiras.count { |j| next unless j.type == type && j.state == state; sum += 1 }
        sum
    end

    # Returns the expected for all jiras of a state (see Jiras::STATES)
    def self.sum_expected(jiras)
        jiras.map(&:expected).inject { |sum, el| sum += el }
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
    def find_all(domain, state)
        return [] unless domain
        domain.each do |item|
            next unless item.xpath(Paths::KEY)
            j = Jira.new(item.xpath(Paths::KEY))
            j.title = item.xpath(Paths::TITLE)
            j.expected = item.xpath(Paths::EXPECTED)
            j.type = item.xpath(Paths::TYPE)
            j.state = state
            @jiras << j
        end
    end

    def to_table_top(temporal)
        "| #{temporal.to_s.capitalize} | #{of_type_and_temporal("Story", temporal).count} | #{of_type_and_temporal("Bug", temporal).count} | #{Jiras.sum_expected(of_type_and_temporal("Story", temporal) + of_type_and_temporal("Bug", temporal)).to_f} |"
    end

    def to_table_top_totals
        str = "|| Total in Sprint || #{of_type_and_temporal("Story", :planned).count + of_type_and_temporal("Story", :added).count + of_type_and_temporal("Story", :removed).count}"
        str += "|| #{of_type_and_temporal("Bug", :planned).count + of_type_and_temporal("Bug", :added).count + of_type_and_temporal("Bug", :removed).count}"
        #str += "|| #{sum_all_expected}\n"
        str += "|| #{Jiras.sum_expected(@jiras)}\n"
        str
    end

    def to_table(state)
        "| #{state.to_s.split('_').map(&:capitalize).join(' ')} | #{count("Story", state)} | #{count("Bug", state)} | #{Jiras.sum_expected(of_state(state)).to_f} |"
    end
end
