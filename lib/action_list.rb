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
			action = Action.new(name, config, @args)

			@actions[name] = action
			if action.alias
				check_duplicate_alias(name, action)
				@aliases[action.alias] = action
			end
		end
	end

	def check_duplicate_alias(name, action)
		return if @aliases[action.alias].nil?

		Output.warn("Duplicate alias '#{action.alias}' detected in action '#{name}'.")
	end
end
