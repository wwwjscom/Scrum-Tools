class Sprint
    attr_accessor :week, :planned, :removed, :added

    # Parse an entires sprint jira board
    def initialize
        @planned, @removed, @added = [], [], []
        parse_week
        @jiras = {}

        Jiras::STATES.each do |state|
            @jiras[state.to_sym] = Jiras.new(state)
        end
    end

    def get_jiras(state)
        @jiras[state]
    end

    # Get all jiras where type is [Story, Bug, etc]
    # and temporal is [:planned, :added, :removed]
    # TODO: Nasty...
    def get_all_jiras(type, temporal)
        jiras = []
        @jiras.each do |state, jira_obj|
            jira_obj.jiras.each do |jira|
                if jira.type == type && jira.temporal == temporal
                    jiras << jira
                end
            end
        end
        jiras
    end

    # TODO: Nasty...also doesn't really belong here...and isn't DRY.
    def sum_expected_for_these_jiras(jiras_array)
        jiras_array.map(&:expected).inject { |sum, el| sum += el }
    end

    # Sums the expected value for all jiras of a given states
    # See Jiras::STATES for valid states.
    def sum_expected(state)
        get_jiras(state).sum_expected
    end

    def sum_all_expected
        sum = 0.0
        Jiras::STATES.each do |state|
            sum += sum_expected(state).to_f
        end
        sum
    end

    #------
    private

    # Returns the week number/name
    def parse_week
        @week = @@doc.xpath("//fixVersion")[0].content
    end
end
