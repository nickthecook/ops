# frozen_string_literal: true

require_relative "../lib/dependency"

class TestDependency < Dependency
	def meet
		execute("bin/some_script")
	end
end
