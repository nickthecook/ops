# frozen_string_literal: true

require 'dependencies/sshkey'

RSpec.describe Dependencies::Sshkey do
	subject { described_class.new(name) }

	let(:name) { "config/$environment/user@host" }
	let(:priv_key_name) { "config/test/user@host" }
	let(:pub_key_name) { "config/test/user@host.pub" }

	describe '#met?' do
		let(:result) { subject.met? }
		let(:priv_key_exists) { true }
		let(:pub_key_exists) { true }
	
		before do
			allow(File).to receive(:exist?).with(priv_key_name).and_return(priv_key_exists)
			allow(File).to receive(:exist?).with(pub_key_name).and_return(pub_key_exists)
		end
	
		it "returns true" do
			expect(result).to eq(true)
		end

		context "when private key does not exist" do
			let(:priv_key_exists) { false }

			it "returns false" do
				expect(result).to eq(false)
			end
		end

		context "when public key does not exist" do
			let(:pub_key_exists) { false }

			it "returns false" do
				expect(result).to eq(false)
			end
		end
	end

	describe "meet" do
		let(:result) { subject.meet }
		let(:dir_exists) { true }

		before do
			allow(Options).to receive(:get).with(anything).and_call_original
			allow(File).to receive(:directory?).with("config/test").and_return(dir_exists)
		end

		it "does not create the directory" do
			expect(FileUtils).not_to receive(:mkdir_p)
			result
		end

		it "creates the key" do
			expect(subject).to receive(:execute).with(/ssh-keygen .*-f #{priv_key_name}.*/)
			result
		end

		it "uses the default key size" do
			expect(subject).to receive(:execute).with(/-b 2048/)
			result
		end

		it "uses the default key algorithm" do
			expect(subject).to receive(:execute).with(/-t rsa/)
			result
		end

		it "does not load secrets" do
			expect(Secrets).not_to receive(:load)
			result
		end

		context "when directory does not exist" do
			let(:dir_exists) { false }

			it "creates the directory" do
				expect(FileUtils).to receive(:mkdir_p).with("config/test")
				result
			end
		end

		context "when load_secrets is true" do
			before do
				allow(Options).to receive(:get).with("sshkey.load_secrets").and_return(true)
			end

			it "loads secrets" do
				expect(Secrets).to receive(:load)
				result
			end
		end

		context "when key size is configured" do
			before do
				allow(Options).to receive(:get).with("sshkey.key_size").and_return(777)
			end

			it "uses the given key size" do
				expect(subject).to receive(:execute).with(/-b 777/)
				result
			end
		end

		context "when key algorithm is configured" do
			before do
				allow(Options).to receive(:get).with("sshkey.key_algo").and_return("afk")
			end

			it "uses the given key algorithm" do
				expect(subject).to receive(:execute).with(/-t afk/)
				result
			end
		end

		context "when passphrase is configured" do
			before do
				allow(Options).to receive(:get).with("sshkey.passphrase").and_return("ssh af")
			end

			it "uses the given passphrase" do
				expect(subject).to receive(:execute).with(/-N 'ssh af'/)
				result
			end

			context "when sshkey passphrase includes an environment variable" do
				before do
					allow(Options).to receive(:get).with("sshkey.passphrase").and_return("$SECRET_PASSPHRASE")
					ENV["SECRET_PASSPHRASE"] = "this is so secret"
				end

				it "expands the variable" do
					expect(subject).to receive(:execute).with(/-N 'this is so secret'/)
					result
				end
			end
		end
	end
end
