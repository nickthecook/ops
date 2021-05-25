# frozen_string_literal: true

require 'builtins/helpers/help_formatter'
require 'builtins/background'

RSpec.describe ::Builtins::Helpers::HelpFormatter do
	describe '.builtin' do
		let(:result) { described_class.builtin(klass, commands) }
		let(:klass) { ::Builtins::Background }
		let(:commands) { %i[background bg] }

		it "returns the list of names that refer to this builtin" do
			expect(result).to match(/background, bg/)
		end

		it "returns the description of the builtin" do
			expect(result).to match(/ runs the given command in a background session/)
		end
	end
end
