# frozen_string_literal: true

require 'dependency'

module Dependencies
	class Dir < Dependency
		def met?
			execute("test -d #{name}")
		end

		def meet
			execute("mkdir -p #{name}")
		end

		def unmeet
			# do nothing; we don't want to delete the directory on an `ops down`
			true
		end

		def should_meet?
			true
		end
	end
end
