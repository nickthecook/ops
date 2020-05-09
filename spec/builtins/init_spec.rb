# frozen_string_literal: true

require 'builtins/init'

RSpec.describe Builtins::Init do
	subject { described_class.new(args, config) }

	let(:args) { {} }
	let(:config) { {} }

	describe '#run' do
		let(:result) { subject.run }
		let(:ops_yml_exists) { false }
		let(:ops_yml_template) { /\/etc\/ops.template.yml$/ }

		before do
			allow(File).to receive(:exist?).with("ops.yml").and_return(ops_yml_exists)
		end

		it "copies the template to ops.yml" do
			expect(FileUtils).to receive(:cp).with(ops_yml_template, "ops.yml")
			result
		end

		context "when ops.yml already exists" do
			let(:ops_yml_exists) { true }

			it "does not overwrite the existing file" do
				expect(FileUtils).not_to receive(:cp)
				result
			end
		end

		context "when template name is given" do
			let(:args) { ["terraform"] }
			let(:ops_yml_template) { /\/etc\/terraform.template.yml$/ }

			it "copies the specified template to ops.yml" do
				expect(FileUtils).to receive(:cp).with(ops_yml_template, "ops.yml")
				result
			end
		end
	end
end
