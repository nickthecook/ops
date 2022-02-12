# frozen_string_literal: true

module Builtins
	class Down < Common::UpDown
		def handle_dependency(dependency)
			dependency.unmeet
		end
	end
end
