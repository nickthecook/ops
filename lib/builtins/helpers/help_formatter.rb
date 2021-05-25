# frozen_string_literal: true

module Builtins
	module Helpers
		class HelpFormatter
			NAME_WIDTH = 40

			class << self
				def builtin(klass, commands)
					cmds_string = commands.map(&:downcase).map(&:to_s).uniq.join(", ").yellow

					format("%<names>-#{NAME_WIDTH}s %<desc>s", names: cmds_string, desc: klass.description)
				end

				def action
				end

				def forward
				end
			end
		end
	end
end
