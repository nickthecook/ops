# frozen_string_literal: true

require 'builtin'

class Nomenclator
	def initialize(action_config)
		@config = action_config
	end

	def action_names(prefix = nil)
		filter(action_list.names, prefix)
	end

	def action_aliases(prefix = nil)
		filter(action_list.aliases, prefix)
	end

	def builtin_names(prefix = nil)
		filter(builtin_list, prefix)
	end

	def commands(prefix = nil)
		action_names(prefix) + action_aliases(prefix) + builtin_names(prefix)
	end

	private

	def filter(list, prefix)
		return list unless prefix

		list.select { |item| item.match(/^#{prefix}/) }
	end

	def builtin_list
		Builtin.class_names.map(&:downcase).map(&:to_s)
	end

	def action_list
		@action_list ||= ActionList.new(@config, [])
	end
end
