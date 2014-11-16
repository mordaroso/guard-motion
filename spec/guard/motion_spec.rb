require 'spec_helper'

module Guard
  describe Motion do
    let(:default_options) do
      {
        :all_after_pass => true, :all_on_start => true, :keep_failed => true,
        :spec_paths => ['spec']
      }
    end
    subject { described_class.new }

    let(:runner)    { mock(described_class::Runner) }

    before do
      described_class::Runner.stub(:new => runner)
    end

    shared_examples_for 'clear failed paths' do
      it 'should clear the previously failed paths' do
        runner.should_receive(:run).with(['spec/foo']) { false }
        expect { subject.run_on_changes(['spec/foo']) }.to throw_symbol :task_has_failed

        runner.should_receive(:run) { true }
        expect { subject.run_all }.to_not throw_symbol # this actually clears the failed paths

        runner.should_receive(:run).with(['spec/bar']) { true }
        subject.run_on_changes(['spec/bar'])
      end
    end

    describe '.initialize' do
      it 'creates a runner' do
        described_class::Runner.should_receive(:new).with(default_options.merge(:foo => :bar))

        described_class.new(:foo => :bar)
      end
    end

    describe '#start' do
      it 'calls #run_all' do
        subject.should_receive(:run_all)
        subject.start
      end

      context ':all_on_start option is false' do
        let(:subject) { subject = described_class.new(:all_on_start => false) }

        it "doesn't call #run_all" do
          subject.should_not_receive(:run_all)
          subject.start
        end
      end
    end

    describe '#run_all' do
      it "runs all specs specified by the default 'spec_paths' option" do
        runner.should_receive(:run) { true }

        subject.run_all
      end

      it "throws task_has_failed if specs don't passed" do
        runner.should_receive(:run) { false }

        expect { subject.run_all }.to throw_symbol :task_has_failed
      end

      it_should_behave_like 'clear failed paths'
    end

    describe '#reload' do
      it_should_behave_like 'clear failed paths'
    end

    describe '#run_on_changes' do
      it 'runs rspec with paths' do
        runner.should_receive(:run).with(['spec/foo']) { true }

        subject.run_on_changes(['spec/foo'])
      end

      context 'the changed specs pass after failing' do
        it 'calls #run_all' do
          runner.should_receive(:run).with(['spec/foo']) { false }

          expect { subject.run_on_changes(['spec/foo']) }.to throw_symbol :task_has_failed

          runner.should_receive(:run).with(['spec/foo']) { true }
          subject.should_receive(:run_all)

          expect { subject.run_on_changes(['spec/foo']) }.to_not throw_symbol
        end

        context ':all_after_pass option is false' do
          subject { described_class.new(:all_after_pass => false) }

          it "doesn't call #run_all" do
            runner.should_receive(:run).with(['spec/foo']) { false }

            expect { subject.run_on_changes(['spec/foo']) }.to throw_symbol :task_has_failed

            runner.should_receive(:run).with(['spec/foo']) { true }
            subject.should_not_receive(:run_all)

            expect { subject.run_on_changes(['spec/foo']) }.to_not throw_symbol
          end
        end
      end

      context 'the changed specs pass without failing' do
        it "doesn't call #run_all" do
          runner.should_receive(:run).with(['spec/foo']) { true }

          subject.should_not_receive(:run_all)

          subject.run_on_changes(['spec/foo'])
        end
      end

      it 'keeps failed spec and rerun them later' do
        subject = described_class.new(:all_after_pass => false)

        runner.should_receive(:run).with(['spec/bar']) { false }

        expect { subject.run_on_changes(['spec/bar']) }.to throw_symbol :task_has_failed

        runner.should_receive(:run).with(['spec/foo', 'spec/bar']) { true }

        subject.run_on_changes(['spec/foo'])

        runner.should_receive(:run).with(['spec/foo']) { true }

        subject.run_on_changes(['spec/foo'])
      end

      it "throws task_has_failed if specs doesn't pass" do
        runner.should_receive(:run).with(['spec/foo']) { false }

        expect { subject.run_on_changes(['spec/foo']) }.to throw_symbol :task_has_failed
      end
    end

  end
end