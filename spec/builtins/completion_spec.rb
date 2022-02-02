# frozen_string_literal: true

require 'builtins/completion'

RSpec.describe Builtins::Completion do
	subject { described_class.new(args, config) }
	let(:args) { [] }
	let(:config) do
		{
			"actions" => {
				"action1" => {
					"command" => "do something",
					"description" => description,
					"in_envs" => ["dev"]
				},
				"action2" => {
					"command" => "do something else",
					"description" => description,
					"not_in_envs" => ["dev"],
					"alias" => "ac2"
				},
				"third_action" => {
					"command" => "do a third thing",
					"description" => description,
					"skip_in_envs" => ["dev2"]
				},
				"other_action" => {
					"command" => "do other things",
					"description" => description
				}
			},
			"forwards" => {
				"backing-test" => "test forward"
			}
		}
	end
	let(:description) { "does something" }
	let(:environment) { "dev" }
	let(:ops_auto_complete) { "1" }
	let(:comp_words) { "ops " }
	let(:comp_cword) { "1" }

	describe '#run' do
		let(:result) { subject.run }

		before do
			allow(Output).to receive(:error)
			allow(Output).to receive(:print)
		end

		context "when no args are supplied" do
			it "prints usage" do
				expect(Output).to receive(:error).with("Usage: ops completion 'bash / zsh'")
				result
			end
		end

		context "when bash is requested" do
			let(:args) { ["bash"] }

			let(:bash_result) do
				"\n\n_ops_completion()\n"\
				"{\n"\
				"    COMPREPLY=( $( COMP_WORDS=\"${COMP_WORDS[*]}\" \\\n"\
				"                   COMP_CWORD=$COMP_CWORD \\\n"\
				"                   OPS_AUTO_COMPLETE=1 $1 2>/dev/null ) )\n"\
				"}\n"\
				"complete -o default -F _ops_completion ops\n"
			end

			it "prints bash formatting" do
				expect(Output).to receive(:print).with(bash_result)
				result
			end
		end

		context "when zsh is requested" do
			let(:args) { ["zsh"] }

			let(:zsh_result) do
				"\n\nfunction _ops_completion {\n"\
				"  local words cword\n"\
				"  read -Ac words\n"\
				"  read -cn cword\n"\
				"  reply=( $( COMP_WORDS=\"$words[*]\" \\\n"\
				"             COMP_CWORD=$(( cword-1 )) \\\n"\
				"             OPS_AUTO_COMPLETE=1 $words[1] 2>/dev/null ))\n"\
				"}\n"\
				"compctl -K _ops_completion ops\n"
			end

			it "prints zsh formatting" do
				expect(Output).to receive(:print).with(zsh_result)
				result
			end
		end
	end

	describe '#completion' do
		let(:result) { subject.completion }

		before do
			allow(Output).to receive(:out)
			allow(ENV).to receive(:[]).with("environment").and_return(environment)
			allow(ENV).to receive(:[]).with("OPS_AUTO_COMPLETE").and_return(ops_auto_complete)
			allow(ENV).to receive(:[]).with("COMP_WORDS").and_return(comp_words)
			allow(ENV).to receive(:[]).with("COMP_CWORD").and_return(comp_cword)
		end

		context "when environment variables are not set" do
			let(:comp_words) { nil }
			let(:comp_cword) { nil }

			it "returns false" do
				expect(result).to be false
			end

			it "doesn't output anything" do
				expect(Output).not_to receive(:out)
				result
			end
		end

		context "when the search terms are empty" do
			it "returns true" do
				expect(result).to be true
			end

			it "outputs all expected actions" do
				expect(Output).to receive(:out).with(a_string_matching(/.*action1.*backing-test.*other_action.*third_action.*/))
				result
			end

			it "doesn't include not_in_envs filtered action" do
				expect(Output).not_to receive(:out).with(a_string_matching(/.*action2.*/))
				result
			end
		end

		context "when searching with a partial search term" do
			let(:comp_words) { "ops ac" }
			let(:comp_cword) { "1" }
			let(:environment) { "dev2" }

			before do
				allow(Options).to receive(:get).with("completion.include_aliases").and_return(true)
			end

			it "returns true" do
				expect(result).to be true
			end

			it "outputs all expected actions" do
				expect(Output).to receive(:out).with(a_string_matching(/.*ac2.*action2.*/))
				result
			end

			it "doesn't include in_envs filtered action" do
				expect(Output).not_to receive(:out).with(a_string_matching(/.*action1.*/))
				result
			end

			it "doesn't include skip_in_envs filtered action" do
				expect(Output).not_to receive(:out).with(a_string_matching(/.*third_action.*/))
				result
			end
		end
	end
end
