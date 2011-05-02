class Comparator

    def initialize(file)
        f = File.open(file)
        @lines = f.readlines.map(&:chomp)
        f.close
    end

    def check(jira)
        type = :planned
        line = jira.to_csv
        if added_to_sprint?(line)
            type = :added
        elsif removed_from_sprint?(line)
            type = :removed
        end
        type
    end


    #---------------
    private

    def added_to_sprint?(line)
        !@lines.include?(line)
    end

    def removed_from_sprint?(line)
        !@lines.include?(line)
    end
end
