# frozen_string_literal: true

require 'action'

RSpec.describe Action do
	subject { described_class.new(action_config, args, options) }
	let(:action_config) { { "command" => "bundle exec rspec" } }
	let(:args) { ["spec/file1.rb", "spec/file2.rb"] }
	let(:options) { nil }

	describe '#to_s' do
		let(:result) { subject.to_s }

		it "appends args to command" do
			expect(result).to eq("bundle exec rspec spec/file1.rb spec/file2.rb")
		end
	end

	describe "#run" do
		let(:result) { subject.run }

		before do
			allow(Kernel).to receive(:exec)
		end

		it "executes the command" do
			expect(Kernel).to receive(:exec).with("bundle exec rspec spec/file1.rb spec/file2.rb")
			result
		end

		it "does not load secrets" do
			expect(Secrets).not_to receive(:new)
			result
		end

		context "when command requires secrets" do
			let(:action_config) { { "command" => "bundle exec rspec", "load_secrets" => true } }
			let(:secrets_double) { instance_double(Secrets) }

			before do
				allow(Secrets).to receive(:new).and_return(secrets_double)
				allow(secrets_double).to receive(:load)
			end

			it "loads secrets" do
				expect(secrets_double).to receive(:load)
				result
			end

			context "when secrets path option is given" do
				let(:options) do
					{
						"secrets" => {
							"path" => secrets_path
						}
					}
				end
				let(:secrets_path) { "development/secrets.ejson" }

				it "loads secrets from the given file" do
					expect(Secrets).to receive(:new).with("development/secrets.ejson")
					result
				end

				context "when secrets path includes a shell variable" do
					let(:secrets_path) { "secrets/$environment/secrets.ejson" }

					it "expands the variable" do
						expect(Secrets).to receive(:new).with("secrets/test/secrets.ejson")
						result
					end
				end
			end
		end
	end
end
