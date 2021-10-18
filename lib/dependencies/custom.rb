# frozen_string_literal: true

require 'dependency'

module Dependencies
	class Custom < Dependency
		class CustomConfigError < StandardError; end

		def initialize(definition)
			super
			@definition = definition
			@name, @config = parse_definition
		end

		def met?
			false
		end

		def always_act?
			true
		end

		def meet
			execute(up_command) if up_command
		end

		def unmeet
			execute(down_command) if down_command
		end

		private

		def up_command
			@up_command ||= @definition.is_a?(Hash) ? @config&.dig("up") : name
		end

		def down_command
			@down_command ||= @config && @config&.dig("down") || nil
		end

		def parse_definition
			return @definition.first if @definition.is_a?(Hash)

			[@definition.to_s, {}]
		end
	end
end
