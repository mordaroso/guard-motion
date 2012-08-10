require 'guard'
require 'guard/guard'

require 'guard/motion/tasks'

module Guard
  class Motion < Guard
    autoload :Runner, 'guard/motion/runner'

    # Initialize a Guard.
    # @param [Array<Guard::Watcher>] watchers the Guard file watchers
    # @param [Hash] options the custom Guard options
    def initialize(watchers = [], options = {})
      super
      @options = {
        :all_after_pass => true,
        :all_on_start   => true,
        :keep_failed    => true,
        :spec_paths     => ["spec"]
      }.merge(options)
      @last_failed  = false
      @failed_paths = []

      @runner = Runner.new(@options)
    end

    # Call once when Guard starts. Please override initialize method to init stuff.
    # @raise [:task_has_failed] when start has failed
    def start
      UI.info "Guard::Motion is running"
      run_all if @options[:all_on_start]
    end

    # Called when `reload|r|z + enter` is pressed.
    # This method should be mainly used for "reload" (really!) actions like reloading passenger/spork/bundler/...
    # @raise [:task_has_failed] when reload has failed
    def reload
      @failed_paths = []
    end

    # Called when just `enter` is pressed
    # This method should be principally used for long action like running all specs/tests/...
    # @raise [:task_has_failed] when run_all has failed
    def run_all
      passed = @runner.run

      unless @last_failed = !passed
        @failed_paths = []
      else
        throw :task_has_failed
      end
    end

    # Called on file(s) modifications that the Guard watches.
    # @param [Array<String>] paths the changes files or paths
    # @raise [:task_has_failed] when run_on_change has failed
    def run_on_changes(paths)
      paths += @failed_paths if @options[:keep_failed]
      paths.uniq!

      if passed = @runner.run(paths)
        remove_failed(paths)

        # run all the specs if the run before this one failed
        if @last_failed && @options[:all_after_pass]
          @last_failed = false
          run_all
        end
      else
        @last_failed = true
        add_failed(paths)

        throw :task_has_failed
      end
    end

    private
    def remove_failed(paths)
      @failed_paths -= paths if @options[:keep_failed]
    end

    def add_failed(paths)
      @failed_paths += paths if @options[:keep_failed]
    end

  end
end
