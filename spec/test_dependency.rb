# frozen_string_literal: true

class TestDependency < Dependency
	def meet
		execute("bin/some_script")
	end
end
