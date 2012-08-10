require 'spec_helper'

module Guard
  class Motion

    describe Runner do
      subject { described_class.new }

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
            subject.should_receive(:system).with(
              "rake spec:specific[\"something\"]"
            ).and_return(true)

            subject.run(['something'])
          end
        end

        context 'in a folder with Bundler' do
          before do
            Dir.stub(:pwd).and_return(@fixture_path.join('bundler'))
          end

          it 'runs with Bundler' do
            subject.should_receive(:system).with(
              "bundle exec rake spec:specific[\"something\"]"
            ).and_return(true)

            subject.run(['something'])
          end

          describe 'notification' do
            it 'notifies when Motion specs fails to execute' do
              subject.should_receive(:rake_command) { "`exit 1`" }
              ::Guard::Notifier.should_receive(:notify).with(
                'Failed', :title => 'Motion spec results', :image => :failed, :priority => 2
              )

              subject.run(['spec'])
            end

            it 'does not notify that Motion specs failed when the specs pass' do
              subject.should_receive(:rake_command) { "`exit 0`" }
              ::Guard::Notifier.should_not_receive(:notify)

              subject.run(['spec'])
            end
          end

          describe 'options' do

            describe ':bundler' do
              context ':bundler => false' do
                subject { described_class.new(:bundler => false) }

                it 'runs without Bundler' do
                  subject.should_receive(:system).with(
                    "rake spec:specific[\"spec\"]"
                  ).and_return(true)

                  subject.run(['spec'])
                end
              end
            end

            describe ':binstubs' do
              context ':bundler => false, :binstubs => true' do
                subject { described_class.new(:bundler => false, :binstubs => true) }

                it 'runs without Bundler and with binstubs' do
                  subject.should_receive(:system).with(
                    "bin/rake spec:specific[\"spec\"]"
                  ).and_return(true)

                  subject.run(['spec'])
                end
              end

              context ':bundler => true, :binstubs => true' do
                subject { described_class.new(:bundler => true, :binstubs => true) }

                it 'runs without Bundler and binstubs' do
                  subject.should_receive(:system).with(
                    "bin/rake spec:specific[\"spec\"]"
                  ).and_return(true)

                  subject.run(['spec'])
                end
              end

              context ':bundler => true, :binstubs => "dir"' do
                subject { described_class.new(:bundler => true, :binstubs => 'dir') }

                it 'runs without Bundler and binstubs in custom directory' do
                  subject.should_receive(:system).with(
                    "dir/rake spec:specific[\"spec\"]"
                  ).and_return(true)

                  subject.run(['spec'])
                end
              end
            end

            describe ':notification' do
              context ':notification => false' do
                subject { described_class.new(:notification => false) }

                it 'runs without notification formatter' do
                  subject.should_receive(:system).with(
                    "bundle exec rake spec:specific[\"spec\"]"
                  ).and_return(true)

                  subject.run(['spec'])
                end

                it "doesn't notify when specs fails" do
                  subject.should_receive(:system) { mock('res', :success? => false, :exitstatus => 2) }
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