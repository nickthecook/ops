# frozen_string_literal: true

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

		it "returns false" do
			expect(result).to eq(false)
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
		let(:agent_double) { instance_double(Net::SSH::Authentication::Agent) }
		let(:unencrypted_key) { "I am an unencrypted SSH key" }
		let(:key_generation_return_value) do
			[
				"command output",
				OpenStruct.new(exitstatus: key_generation_exit_status)
			]
		end
		let(:key_generation_exit_status) { 0 }
		let(:priv_key_exists) { false }
		let(:pub_key_exists) { false }

		before do
			allow(Options).to receive(:get).with(anything).and_call_original
			allow(File).to receive(:directory?).with("config/test").and_return(dir_exists)
			allow(Net::SSH::Authentication::Agent).to receive(:connect).and_return(agent_double)
			allow(agent_double).to receive(:add_identity)
			allow(Open3).to receive(:capture2e).with(/ssh-keygen /).and_return(key_generation_return_value)
			allow(Net::SSH::KeyFactory).to receive(:load_private_key).and_return(unencrypted_key)
			allow(Output).to receive(:warn)
			allow(Ops).to receive(:project_name).and_return("some_project")

			# for simulating key exists and key doesn't exist scenarios
			allow(File).to receive(:exist?)
			allow(File).to receive(:exist?).with(priv_key_name).and_return(priv_key_exists)
			allow(File).to receive(:exist?).with(pub_key_name).and_return(pub_key_exists)
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
			expect(subject).to receive(:execute).with(/-b 4096/)
			result
		end

		it "uses the default key algorithm" do
			expect(subject).to receive(:execute).with(/-t rsa/)
			result
		end

		it "passes the unencrypted key to the ssh-agent" do
			expect(agent_double).to receive(:add_identity).with(
				"I am an unencrypted SSH key",
				anything,
				anything
			)
			result
		end

		it "adds the key with the project name as the comment" do
			expect(agent_double).to receive(:add_identity).with(
				anything,
				"some_project",
				anything
			)
			result
		end

		it "adds the key with the correct lifetime" do
			expect(agent_double).to receive(:add_identity).with(
				anything,
				anything,
				lifetime: 3600
			)
			result
		end

		it "warns the user about passphrase not being set" do
			expect(Output).to receive(:warn).with("\nNo passphrase set for SSH key '#{priv_key_name}'")
			result
		end

		context "when key generation fails" do
			let(:key_generation_exit_status) { 1 }

			it "does not attempt to add the SSH key" do
				expect(Net::SSH::Authentication::Agent).not_to receive(:connect)
				result
			end
		end

		context "when no SSH agent is available" do
			before do
				allow(ENV).to receive(:[]).and_call_original
				allow(ENV).to receive(:[]).with("SSH_AUTH_SOCK").and_return(nil)
			end

			it "does not attempt to add the SSH key" do
				expect(Net::SSH::Authentication::Agent).not_to receive(:connect)
				result
			end
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

		context "when passphrase_var is configured" do
			before do
				allow(Options).to receive(:get).with("sshkey.passphrase_var").and_return("SECRET_PASSPHRASE")
				ENV["SECRET_PASSPHRASE"] = "this is even secreter"
			end

			it "expands the variable with the given name" do
				expect(subject).to receive(:execute).with(/-N 'this is even secreter'/)
				result
			end
		end

		context "when key algorithm is configured" do
			before do
				allow(Options).to receive(:get).with("sshkey.key_algo").and_return("ed25519")
			end

			it "uses the configured key algorithm" do
				expect(subject).to receive(:execute).with(/-t ed25519/)
				result
			end
		end

		context "when key lifetime is configured" do
			before do
				allow(Options).to receive(:get).with("sshkey.key_lifetime").and_return(123)
			end

			it "uses the configured key lifetime" do
				expect(agent_double).to receive(:add_identity).with(anything, anything, lifetime: 123)
				result
			end
		end

		context "when key adding is disabled" do
			before do
				allow(Options).to receive(:get).with("sshkey.add_keys").and_return(false)
			end

			it "does not add the key to the SSH agent" do
				expect(Net::SSH::Authentication::Agent).not_to receive(:connect)
				result
			end
		end

		context "when key exists" do
			let(:priv_key_exists) { true }
			let(:pub_key_exists) { true }

			it "warns the user about passphrase not being set" do
				expect(Output).to receive(:warn).with("\nNo passphrase set for SSH key '#{priv_key_name}'")
				result
			end
		end

		context "when key comment option is given" do
			before do
				allow(Options).to receive(:get).with("sshkey.key_file_comment").and_return("some_team@some_company")
			end

			it "uses the configured comment" do
				expect(subject).to receive(:execute).with(/-C 'some_team@some_company'/)
				result
			end
		end
	end
end
