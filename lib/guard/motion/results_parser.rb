module Guard
  class Motion
    class ResultsParser
      attr_reader :errors
      attr_reader :failures
      attr_reader :specs
      
      def parse(output)
        matched = false

        stats_regex = /(\d+) (tests|specifications),? \(?\d+ (assertions|requirements)\)?, (\d+) failures, (\d+) errors/
        stats_regex.match(output) do |m|
          matched = true

          @specs = m[1].to_i
          @failures = m[4].to_i
          @errors = m[5].to_i
        end

        matched
      end

      def success?
        errors == 0 && failures == 0
      end
    end
  end
end
