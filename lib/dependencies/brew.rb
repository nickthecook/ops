# frozen_string_literal: true

require 'dependency'

module Dependencies
	class Brew < Dependency
		NAME_REF_SEPARATOR = '/'

		def met?
			execute("brew list #{package_name} | grep #{name}")
		end

		def meet
			# no version info in name; just install the package by name and return
			return execute("brew install #{name}") unless name.include?(NAME_REF_SEPARATOR)

			return unless check_out_brew_git_ref(git_ref)
			return unless unlink_installed_package
			return unless install_package
			return unless link_new_package

			unset_brew_git_ref
		end

		def unmeet
			# do nothing; we don't want to uninstall packages and reinstall them every time
			true
		end

		def should_meet?
			`uname`.chomp == "Darwin"
		end

		private

		def check_out_brew_git_ref(ref)
			puts "checkout"
			execute("cd #{brew_formula_dir} && git checkout #{ref}")
		end

		def unlink_installed_package
			puts "unlink"
			execute("brew unlink #{package_name}")
		end

		def install_package
			puts "install"
			execute("HOMEBREW_NO_AUTO_UPDATE=1 brew install #{name.split(NAME_REF_SEPARATOR).first}")
		end

		def link_new_package
			puts "link"
			execute("brew link #{package_name}")
		end

		def unset_brew_git_ref
			puts "unset"
			execute("cd #{brew_formula_dir} && git checkout master")
		end

		def brew_formula_dir
			`brew --repo homebrew/core`.chomp
		end

		def package_name
			name_components.first
		end

		def git_ref
			name_components.last
		end

		def name_components
			name.split(NAME_REF_SEPARATOR, 2)
		end
	end
end
