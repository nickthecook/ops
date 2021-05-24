# frozen_string_literal: true

require 'builtin_list'
require 'builtins/background'

RSpec.describe BuiltinList do
	let(:constants) { %i[Bg Background Up Down] }

	before do
		allow(Builtins).to receive(:constants).and_return(constants)
	end

	describe "#names" do
		let(:result) { subject.names }

		it "returns a list of builtins" do
			expect(result).to eq(%i[Bg Background Up Down])
		end
	end

	describe "#get" do
		it "returns the const for the given name" do
			expect(subject.get(:Bg)).to eq(Builtins::Bg)
		end
	end

	describe "#builtins" do
		let(:result) { subject.builtins }

		it "returns a hash" do
			expect(result).to be_a(Hash)
		end

		it "has builtin names as keys" do
			expect(result.keys).to include(:Bg, :Background, :Up, :Down)
		end

		it "has builtin classes as values" do
			expect(result.values).to include(Builtins::Bg, Builtins::Background, Builtins::Up, Builtins::Down)
		end
	end

	describe "#commands" do
		let(:result) { subject.commands }

		it "returns a hash" do
			expect(result).to be_a(Hash)
		end

		it "returns three keys" do
			expect(result.count).to eq(3)
		end

		it "has builtin classes as keys" do
			expect(result.keys).to include(Builtins::Background, Builtins::Up, Builtins::Down)
		end

		it "has arrays of builtin names as values" do
			expect(result.values).to include(%i[Bg Background], %i[Up], %i[Down])
		end
	end
end
