class Jira
    attr_accessor :key, :expected, :type, :title, :planned, :added, :removed

    def initialize(key)
        @key = key[0].content.strip
    end

    def expected=(e)
        @expected = (e[0]) ? ("%.2f" % e[0].content.strip).to_f : 0.0
    end

    def type=(t)
        @type = t[0].content.strip
    end

    # Used to serialize the objects
    def to_csv
        "#{@key},#{@expected},#{@type}"
    end

end
