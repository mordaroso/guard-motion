module Guard
  class Motion
    class Runner

      def initialize(options = {})
        @options = {
          :bundler      => true,
          :binstubs     => false,
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

        run_via_shell rake_command(paths)
      end

      def rake_executable
        @rake_executable ||= begin
          binstubs? ? "#{binstubs}/rake" : 'rake'
        end
      end

      def rake_command(paths)
        cmd_parts = []
        cmd_parts << "bundle exec" if bundle_exec?
        cmd_parts << rake_executable
        cmd_parts << "spec:specific[\"#{paths.join(';')}\"]"
        cmd_parts.compact.join(' ')
      end

      def run_via_shell(command)
        success = system(command)

        if @options[:notification] && !success
          Notifier.notify("Failed", :title => "Motion spec results", :image => :failed, :priority => 2)
        end

        success
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