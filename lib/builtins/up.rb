# frozen_string_literal: true

require 'require_all'
require_rel "../dependencies"

require 'builtins/common/up_down'
require 'output'

module Builtins
	class Up < Common::UpDown
		def handle_dependency(dependency)
			dependency.meet
		end
	end
end
