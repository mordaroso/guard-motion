require 'spec_helper'

module Guard
  class Motion

    describe Runner do
      subject { described_class.new }

      let(:output) { "..............................\n\n31 tests, 35 assertions, 2 failures, 0 errors\n" }

      before do
        PTY.stub(:spawn).and_yield(StringIO.new(output), StringIO.new, 123)
        subject.stub(:print)
        Process.stub(:wait)
      end

      describe '#run' do
        context 'when passed an empty paths list' do
          it 'returns false' do
            subject.run([]).should be_false
          end
        end

        context 'in a folder without Bundler' do
          before do
            Dir.stub(:pwd).and_return(@fixture_path.join('empty'))
          end

          it 'runs without bundler' do
            PTY.should_receive(:spawn).with(
              "rake spec:specific[\"something\"]"
            )

            subject.run(['something'])
          end
        end

        context 'in a folder with Bundler' do
          before do
            Dir.stub(:pwd).and_return(@fixture_path.join('bundler'))
          end

          it 'runs with Bundler' do
            PTY.should_receive(:spawn).with(
              "bundle exec rake spec:specific[\"something\"]"
            )

            subject.run(['something'])
          end

          context 'when two files refer to the same location' do
            it 'ignores the second file' do
              PTY.should_receive(:spawn).with(
                "bundle exec rake spec:specific[\"first\"]"
              )

              subject.run(['first', './first', 'second/../first'])
            end
          end

          describe 'notification' do
            context "when the specs fail to execute" do
              let(:output) { "" }

              it "sends a failure notification" do
                ::Guard::Notifier.should_receive(:notify).with(
                  'Failed', :title => 'RubyMotion Spec Results', :type => :failed, :image => :failed, :priority => 2
                )

                subject.run(['spec'])
              end
            end

            context "when the specs fail" do
              let(:output) { "..............................\n\n31 tests, 35 assertions, 2 failures, 0 errors\n" }

              it "sends a spec failed notification" do
                ::Guard::Notifier.should_receive(:notify).with(
                  '31 specs, 2 failures, 0 errors', :title => 'RubyMotion Spec Results', :type => :failed, :image => :failed, :priority => 2)

                subject.run(["spec"])
              end
            end

            context "when specs pass" do
              let(:output) { "..............................\n\n31 tests, 35 assertions, 0 failures, 0 errors\n" }

              it "sends a success notification" do
                ::Guard::Notifier.should_receive(:notify).with(
                  '31 specs, 0 failures, 0 errors', :title => 'RubyMotion Spec Results', :type => :success, :image => :success, :priority => 2
                )

                subject.run(['spec'])
              end
            end
          end

          describe 'options' do

            describe ':bundler' do
              context ':bundler => false' do
                subject { described_class.new(:bundler => false) }

                it 'runs without Bundler' do
                  PTY.should_receive(:spawn).with(
                    "rake spec:specific[\"spec\"]"
                  )

                  subject.run(['spec'])
                end
              end
            end

            describe ':binstubs' do
              context ':bundler => false, :binstubs => true' do
                subject { described_class.new(:bundler => false, :binstubs => true) }

                it 'runs without Bundler and with binstubs' do
                  PTY.should_receive(:spawn).with(
                    "bin/rake spec:specific[\"spec\"]"
                  )

                  subject.run(['spec'])
                end
              end

              context ':bundler => true, :binstubs => true' do
                subject { described_class.new(:bundler => true, :binstubs => true) }

                it 'runs without Bundler and binstubs' do
                  PTY.should_receive(:spawn).with(
                    "bin/rake spec:specific[\"spec\"]"
                  )

                  subject.run(['spec'])
                end
              end

              context ':bundler => true, :binstubs => "dir"' do
                subject { described_class.new(:bundler => true, :binstubs => 'dir') }

                it 'runs without Bundler and binstubs in custom directory' do
                  PTY.should_receive(:spawn).with(
                    "dir/rake spec:specific[\"spec\"]"
                  )

                  subject.run(['spec'])
                end
              end
            end

            describe ':notification' do
              context ':notification => false' do
                subject { described_class.new(:notification => false) }

                it 'runs without notification formatter' do
                  PTY.should_receive(:spawn).with(
                    "bundle exec rake spec:specific[\"spec\"]"
                  )

                  subject.run(['spec'])
                end

                it "doesn't notify when specs fails" do
                  PTY.should_receive(:spawn).with(
                    "bundle exec rake spec:specific[\"spec\"]"
                  )

                  ::Guard::Notifier.should_not_receive(:notify)

                  subject.run(['spec'])
                end
              end
            end
          end
        end
      end
    end
  end
end
