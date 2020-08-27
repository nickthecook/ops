# frozen_string_literal: true

module Dependencies
	module Helpers
		class AptCachePolicy
			INSTALLED_VERSION_REGEX = /  Installed: ([-+.a-z0-9]+)/.freeze

			attr_reader :name

			def initialize(name)
				@name = name
			end

			def installed_version
				version_from_policy_version_line(installed_version_line)
			end

			def installed?
				!!installed_version
			end

			private

			def installed_version_line
				apt_cache_lines.find { |line| line.match(/#{INSTALLED_VERSION_REGEX}/) }
			end

			def version_from_policy_version_line(line)
				return nil if line.nil?

				# E.g.:
				#  Installed: 7.52.1-5+deb9u7
				match = line.match(/#{INSTALLED_VERSION_REGEX}/)

				match.nil? ? nil : match[1]
			end

			def version_lines
				@version_lines ||= begin
					version_table_index = apt_cache_lines.find_index { |line| line.match?(/Version table:/) }

					apt_cache_lines[version_table_index..-1].each_with_object([]) do |line, versions|
						next unless line.match(/ *(\*\*\*)? .*/)

						versions << line
					end
				end
			end

			def apt_cache_lines
				@apt_cache_lines ||= `apt-cache policy #{name}`.split("\n")
			end
		end
	end
end
