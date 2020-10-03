# frozen_string_literal: true

class ActionList
	class UnknownActionError < StandardError; end

	def initialize(actions_list, args)
		@actions_list = actions_list
		@args = args

		process_action_list
	end

	def get(name)
		@actions[name]
	end

	def get_by_alias(name)
		@aliases[name]
	end

	def names
		@actions.keys
	end

	def aliases
		@aliases.keys
	end

	private

	def actions_list
		@actions_list ||= []
	end

	def process_action_list
		@actions = {}
		@aliases = {}

		actions_list.each do |name, config|
			action = Action.new(config, @args)

			@actions[name] = action
			@aliases[action.alias] = action
		end
	end
end
