# frozen_string_literal: true

class ActionSuggester
	def initialize(dictionary)
		@dictionary = dictionary
	end

	def check(word)
		spellchecker.correct(word)
	end

	private

	def spellchecker
		@spellchecker ||= DidYouMean::SpellChecker.new(dictionary: @dictionary)
	end
end
