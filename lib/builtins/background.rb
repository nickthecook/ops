# frozen_string_literal: true

require 'open3'

require 'builtin'

module Builtins
	class Background < Builtin
		class << self
			def description
				"runs the given command in a background session"
			end
		end

		def run
			exec("tmux", "new", "-d", "ops #{args.join(' ')}")
		end
	end
end
