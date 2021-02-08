# frozen_string_literal: true

require 'nomenclator'

RSpec.describe Nomenclator do
	subject { described_class.new(action_config) }

	let(:action_config) do
		{
			"run" => {
				"command" => "run_the_thing with_arg",
				"alias" => "r"
			},
			"stop" => {
				"command" => "stop_the_thing with_arg",
				"alias" => "s"
			},
			"status" => {
				"command" => "status_the_thing"
			},
			"build" => {
				"command" => "bin/build",
				"alias" => "b"
			}
		}
	end

	describe "#action_names" do
		let(:result) { subject.action_names }

		it "returns the list of action names" do
			expect(result).to eq(%w[run stop status build])
		end

		context "when prefix given" do
			let(:result) { subject.action_names("st") }

			it "returns only matching actions" do
				expect(result).to eq(%w[stop status])
			end
		end
	end

	describe "#action_aliases" do
		let(:result) { subject.action_aliases }

		it "returns a list of aliases" do
			expect(result).to eq(%w[r s b])
		end

		context "when prefix given" do
			let(:result) { subject.action_aliases("s") }

			it "returns only matching aliases" do
				expect(result).to eq(%w[s])
			end
		end
	end

	describe "builtin_names" do
		let(:result) { subject.builtin_names }

		before do
			allow(Builtin).to receive(:class_names).and_return(%i[One Two])
		end

		it "returns a list of builtins" do
			expect(result).to eq(%w[one two])
		end

		context "when prefix is given" do
			let(:result) { subject.builtin_names("tw") }

			it "returns only matching builtins" do
				expect(result).to eq(%w[two])
			end
		end
	end

	describe "#commands" do
		let(:result) { subject.commands }

		before do
			allow(Builtin).to receive(:class_names).and_return(%i[Bg Bglog Up])
		end

		it "returns a list of actions, aliases, and builtins" do
			expect(result).to contain_exactly("run", "r", "stop", "s", "build", "b", "status", "bg", "bglog", "up")
		end

		context "when prefix is given" do
			let(:result) { subject.commands("b") }

			it "returns only matching commands" do
				expect(result).to contain_exactly("build", "b", "bg", "bglog")
			end
		end
	end
end
