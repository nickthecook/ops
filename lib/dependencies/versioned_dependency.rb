# frozen_string_literal: true

module Dependencies
	class VersionedDependency < Dependency
		VERSION_SEPARATOR = " "

		def dep_name
			name_components[0]
		end

		def dep_version
			name_components[1]
		end

		def versioned?
			!!dep_version
		end

		private

		def name_components
			name.split(VERSION_SEPARATOR, 2)
		end
	end
end
