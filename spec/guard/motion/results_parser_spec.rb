require 'spec_helper'

module Guard
  class Motion
    describe ResultsParser do
      describe "#parse" do
        before do
          @result = subject.parse(output)
        end

        context "when the output contains spec output" do
          context "and specs failed" do
            let(:output) { ".................FFF...\n18 tests, 21 assertions, 3 failures, 1 errors\n" }
          
            it "returns true" do
              @result.should be_true
            end

            it "does not consider it successful" do
              subject.success?.should be_false
            end

            it "returns the number of tests run" do
              subject.specs.should == 18
            end

            it "returns the number of failures" do
              subject.failures.should == 3
            end

            it "returns the number of errors" do
              subject.errors.should == 1
            end
          end

          context "and specs passed" do
            let(:output) { ".................FFF...\n18 tests, 21 assertions, 0 failures, 0 errors\n" }

            it "returns true" do
              @result.should be_true
            end

            it "considers the test run successful" do
              subject.success?.should be_true
            end

            it "returns the number of tests run" do
              subject.specs.should == 18
            end

            it "returns the number of failures" do
              subject.failures.should == 0
            end

            it "returns the number of errors" do
              subject.errors.should == 0
            end
          end
        end

        context "when the output does not contain spec output" do
          let(:output) { "" }

          it "returns false" do
            @result.should be_false
          end

          it "does not consider the test successful" do
            subject.success?.should be_false
          end

          it "returns nil for test count" do
            subject.specs.should_not be
          end

          it "returns nil for failure count" do
            subject.failures.should_not be
          end

          it "returns nil for error count" do
            subject.errors.should_not be
          end
        end
      end
    end
  end
end
