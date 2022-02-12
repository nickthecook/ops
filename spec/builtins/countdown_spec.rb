# frozen_string_literal: true

RSpec.describe Builtins::Countdown do
	subject { described_class.new(args, config) }
	let(:args) { [3] }
	let(:config) { {} }

	describe "#run" do
		let(:result) { subject.run }
		let(:task_double) { instance_double(Concurrent::TimerTask) }

		before do
			allow(Concurrent::TimerTask).to receive(:new).and_return(task_double)
			allow(subject).to receive(:sleep)
			allow(task_double).to receive(:execute)
			allow(task_double).to receive(:running?).and_return(true, true, true, false)
			allow(task_double).to receive(:shutdown)
		end

		it "sleeps before returning" do
			expect(subject).to receive(:sleep).exactly(3).times
			result
		end

		it "prints a message when done" do
			expect(Output).to receive(:out).with("\rCountdown complete after 3s.")
			result
		end

		context "when the task stops before the time is up" do
			# this shouldn't really come up, but if a thread dies it will
			before do
				allow(task_double).to receive(:running?).and_return(true, false)
			end

			it "exits immediately" do
				expect(subject).to receive(:sleep).exactly(1).time
				result
			end
		end
	end
end
