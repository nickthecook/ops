# frozen_string_literal: true

require 'builtins/background_log'

RSpec.describe Builtins::BackgroundLog do
	subject { described_class.new(args, config) }
	let(:args) { [] }
	let(:config) { {} }

	describe "#run" do
		let(:result) { subject.run }
		let(:file_exists) { true }

		before do
			allow(subject).to receive(:exec)
			allow(File).to receive(:exist?).with('/tmp/ops_bglog_ops').and_return(file_exists)
		end

		it "runs 'tail' in a shell" do
			expect(subject).to receive(:exec).with("tail  '/tmp/ops_bglog_ops'")
			result
		end

		it "uses Builtins::Background to get the name of the log file" do
			expect(Builtins::Background).to receive(:log_filename).with(no_args).exactly(3).times.and_call_original
			result
		end

		it "sets an alias that is convenient for the user" do
			expect(Builtins::Bglog).to eq(Builtins::BackgroundLog)
		end

		context "when args are given" do
			let(:args) { ["-f -n 100"] }

			it "passes the args on to 'tail'" do
				expect(subject).to receive(:exec).with("tail -f -n 100 '/tmp/ops_bglog_ops'")
				result
			end
		end
	end
end
