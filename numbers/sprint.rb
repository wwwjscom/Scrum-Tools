class Sprint
    attr_accessor :week, :planned, :removed, :added

    # Parse an entires sprint jira board
    def initialize
        @planned, @removed, @added = [], [], []
        parse_week
        @jiras = {}

        Jiras::STATES.each do |state|
            (@jiras[state.to_sym] = Jiras.new(state)).find_all
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
