# frozen_string_literal: true

require 'action'

RSpec.describe Action do
	subject { described_class.new(command, args) }
	let(:command) { "bundle exec rspec" }
	let(:args) { ["spec/file1.rb", "spec/file2.rb"] }

	describe '#to_s' do
		let(:result) { subject.to_s }

		it "appends args to command" do
			expect(result).to eq("bundle exec rspec spec/file1.rb spec/file2.rb")
		end
	end
end
