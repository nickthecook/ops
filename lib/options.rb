# frozen_string_literal: true

class Options
	class << self
		def get(path)
			@options.dig(*path.split('.'))
		end

		def set(options)
			@options = options
		end
	end
end
