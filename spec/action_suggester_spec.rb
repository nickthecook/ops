# frozen_string_literal: true

require 'action_suggester'

RSpec.describe ActionSuggester do
	subject { described_class.new(words) }

	let(:words) { %w[one two three threee] }

	describe "#check" do
		let(:result) { subject.check(word) }
		let(:word) { "thref" }
		let(:spellchecker_double) { instance_double(DidYouMean::SpellChecker, correct: %w[three threee]) }

		before do
			allow(DidYouMean::SpellChecker).to receive(:new).and_return(spellchecker_double)
		end

		it "calls SpellChecker#correct" do
			expect(spellchecker_double).to receive(:correct).with("thref")
			result
		end

		it "returns all suggestions" do
			expect(result).to eq(%w[three threee])
		end
	end
end
