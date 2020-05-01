# frozen_string_literal: true

require 'dependency'

class TestDependency < Dependency
	def meet
		execute("bin/some_script")
	end
end
