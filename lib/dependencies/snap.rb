# frozen_string_literal: true

module Dependencies
	class Snap < VersionedDependency
		def met?
			system("snap list | grep -q \"^name \"")
		end

		def meet
			execute("#{sudo_string}snap install #{name}")
		end

		def unmeet
			# do nothing; we don't want to uninstall packages and reinstall them every time
			true
		end

		def should_meet?
			return false unless Options.get("snap.install")
			return false unless `uname`.chomp == "Linux"
			return false unless system("which snap", out: File::NULL, err: File::NULL)

			true
		end

		private

		def sudo_string
			return "sudo " unless Options.get("snap.use_sudo") == false
		end
	end
end
