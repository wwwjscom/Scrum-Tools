class Sprint
    attr_accessor :week, :planned, :removed, :added

    # Parse an entires sprint jira board
    def initialize
        @planned, @removed, @added = [], [], []
        parse_week
        @jiras = {}

        @jiras[state.to_sym] = Jiras.new
        Jiras::STATES.each do |state|

            @domain = case state
                      when :open then @@doc.xpath(Paths::OPEN)
                      when :in_progress then @@doc.xpath(Paths::IN_PROGRESS)
                      when :ready_for_review then @@doc.xpath(Paths::RFR)
                      when :ready_for_acc_testing then @@doc.xpath(Paths::RFAT)
                      when :closed then @@doc.xpath(Paths::CLOSED)
                      when :backlog then @@doc.xpath(Paths::BACKLOG)
                      end

        end
    end

    def get_jiras(state)
        @jiras[state]
    end

    # Sums the expected value for all jiras of a given states
    # See Jiras::STATES for valid states.
    def sum_expected(state)
        get_jiras(state).sum_expected
    end

    #------
    private

    # Returns the week number/name
    def parse_week
        @week = @@doc.xpath("//fixVersion")[0].content
    end
end
