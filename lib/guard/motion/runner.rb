require 'pty'

module Guard
  class Motion
    class Runner
      def initialize(options = {})
        @options = {
          :bundler      => true,
          :binstubs     => false,
          :env          => {},
          :notification => true,
        }.merge(options)
      end

      def run(paths = nil, options = {})
        if paths.nil?
          paths = all_spec_paths
          message = options[:message] || "Running all specs"
        else
          message = options[:message] || "Running: #{paths.join(' ')}"
        end

        return false if paths.empty?

        UI.info(message, :reset => true)

        output = run_via_pty rake_command(paths)

        if @options[:notification]
          notify(output)
        end
      end

      def notify(output)
        message = "Failed"
        type = :failed

        parser = ResultsParser.new
        if parser.parse(output)
          message = "#{parser.specs} specs, #{parser.failures} failures, #{parser.errors} errors"
        end

        if parser.success?
          type = :success
        end

        Notifier.notify(message, :image => type, :title => 'RubyMotion Spec Results', :priority => 2)
      end

      def rake_executable
        @rake_executable ||= begin
          binstubs? ? "#{binstubs}/rake" : 'rake'
        end
      end

      def rake_command(paths)
        cmd_parts = []

        @options[:env].each do |var, value|
          cmd_parts << "#{var}=#{value}"
        end

        cmd_parts << "bundle exec" if bundle_exec?
        cmd_parts << rake_executable
        cmd_parts << "spec:specific[\"#{paths.join(';')}\"]"
        cmd_parts.compact.join(' ')
      end

      def run_via_pty(command)
        output = ""

        PTY.spawn(command) do |r, w, pid|
          begin
            loop do
              chunk = r.readpartial(1024)
              output += chunk

              print chunk
            end
          rescue EOFError
          end

          Process.wait(pid)
        end

        output
      end

      def all_spec_paths
        @options[:spec_paths].map { |spec_path|
          Dir.glob("#{spec_path}/**/*_spec.rb")
        }.flatten
      end

      def bundler_allowed?
        if @bundler_allowed.nil?
          @bundler_allowed = File.exist?("#{Dir.pwd}/Gemfile")
        else
          @bundler_allowed
        end
      end

      def bundler?
        if @bundler.nil?
          @bundler = bundler_allowed? && @options[:bundler]
        else
          @bundler
        end
      end

      def binstubs?
        if @binstubs.nil?
          @binstubs = !!@options[:binstubs]
        else
          @binstubs
        end
      end

      def binstubs
        if @options[:binstubs] == true
          "bin"
        else
          @options[:binstubs]
        end
      end

      def bundle_exec?
        bundler? && !binstubs?
      end
    end
  end
end
