# frozen_string_literal: true

module Builtins
	class Up < Common::UpDown
		def handle_dependency(dependency)
			dependency.meet
		end
	end
end
