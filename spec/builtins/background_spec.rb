# frozen_string_literal: true

require "builtins/background"

RSpec.describe Builtins::Background do
	subject { described_class.new(args, config) }
	let(:args) { [] }
	let(:config) { {} }

	describe "#run" do
		let(:result) { subject.run }
		let(:process_double) { instance_double(Process) }
		let(:ops_double) { instance_double(Ops, run: true) }

		def spoon
			yield

			process_double
		end

		before do
			allow(subject).to receive(:fork) { |&block| spoon(&block) }
			allow(Process).to receive(:detach).and_return(true)
			allow($stdout).to receive(:reopen).and_return(true)
			allow($stderr).to receive(:reopen).and_return(true)
			allow(Ops).to receive(:new).and_return(ops_double)
			allow(Ops).to receive(:project_name).and_return("some_project")
		end

		it "forks" do
			expect(subject).to receive(:fork)
			result
		end

		it "detaches from the child process" do
			expect(Process).to receive(:detach).with(process_double)
			result
		end

		it "prints a message about redirecting output" do
			expect(Output).to receive(:warn).with(/Running .* with stderr and stdout redirected to /)
			result
		end

		it "enables sync output on stdout" do
			expect($stdout).to receive(:sync=).with(true)
			result
		end

		it "enables sync output on stderr" do
			expect($stderr).to receive(:sync=).with(true)
			result
		end

		it "creates and instance of Ops with the given arguments" do
			expect(Ops).to receive(:new).with(args)
			result
		end

		it "runs the instance of Ops" do
			expect(ops_double).to receive(:run)
			result
		end

		it "redirects stdout to the correct file" do
			expect($stdout).to receive(:reopen).with("/tmp/ops_bglog_some_project", "w")
			result
		end

		it "redirects stderr to stdout" do
			expect($stderr).to receive(:reopen).with($stdout)
			result
		end
	end
end
